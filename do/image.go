package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/digitalocean/godo"
)

func cmdImage(ctx context.Context, cfg *Config, args []string) error {
	if len(args) < 1 || args[0] != "build" {
		return fmt.Errorf("usage: image build [--teardown]")
	}
	teardown := false
	for _, a := range args[1:] {
		if a == "--teardown" {
			teardown = true
		}
	}
	if err := imageBuild(ctx, cfg); err != nil {
		return err
	}
	if teardown {
		fmt.Println("--teardown: destroying build host...")
		return buildHostDown(ctx, cfg)
	}
	fmt.Println("Build host left running. Destroy with: task do:build-host:down")
	return nil
}

func imageBuild(ctx context.Context, cfg *Config) error {
	if err := cfg.requireToken(); err != nil {
		return err
	}
	if err := cfg.requireSpaces(); err != nil {
		return err
	}
	if err := cfg.ensureStateDir(); err != nil {
		return err
	}

	host, err := loadHost(cfg.buildHostPath())
	if err != nil {
		return fmt.Errorf("no build host state; run: build-host up")
	}

	if err := cfg.waitSSH(host.IP); err != nil {
		return err
	}
	if err := cfg.ensureNix(host.IP); err != nil {
		return err
	}

	imgPath, err := buildBootstrapImage(cfg, host.IP)
	if err != nil {
		return err
	}
	fmt.Printf("Built image: %s\n", imgPath)

	objectKey := fmt.Sprintf("nixos-do-images/%s-%s.qcow2.gz", cfg.ImageName, time.Now().UTC().Format("20060102T150405Z"))
	imageURL := cfg.spacesPublicURL(objectKey)

	fmt.Printf("Uploading to Spaces %s / %s ...\n", cfg.SpacesBucket, objectKey)
	if err := uploadSpaces(ctx, cfg, imgPath, objectKey); err != nil {
		return err
	}

	client := cfg.doClient(ctx)
	if err := deleteNamedImages(ctx, client, cfg.ImageName); err != nil {
		fmt.Printf("warning: deleting existing images: %v\n", err)
	}

	fmt.Printf("Registering custom image from %s ...\n", imageURL)
	created, _, err := client.Images.Create(ctx, &godo.CustomImageCreateRequest{
		Name:         cfg.ImageName,
		Url:          imageURL,
		Region:       host.Region,
		Distribution: "Unknown",
		Tags:         []string{"nixos"},
	})
	if err != nil {
		return fmt.Errorf("create custom image: %w", err)
	}

	fmt.Printf("Waiting for custom image %d to become available...\n", created.ID)
	status, err := waitImageAvailable(ctx, client, created.ID)
	if err != nil {
		fmt.Printf("Spaces object left in place for retry/debug: %s\n", imageURL)
		return err
	}

	fmt.Printf("Image available — removing Spaces object s3://%s/%s ...\n", cfg.SpacesBucket, objectKey)
	if err := deleteSpaces(ctx, cfg, objectKey); err != nil {
		return fmt.Errorf("image is available but Spaces cleanup failed: %w", err)
	}
	fmt.Println("Spaces object deleted.")

	st := ImageState{
		ID:            strconv.Itoa(created.ID),
		Name:          created.Name,
		Region:        host.Region,
		Status:        status,
		SpacesURL:     imageURL,
		SpacesObject:  objectKey,
		SpacesDeleted: true,
	}
	if err := writeJSON(cfg.imagePath(), st); err != nil {
		return err
	}
	fmt.Printf("Custom image ready: %s (%d)\n", created.Name, created.ID)
	fmt.Printf("State written to %s\n", cfg.imagePath())
	fmt.Println("Next: task do:dev:up, then on the droplet: task switch (flake attr do-cloud-dev)")
	return nil
}

func buildBootstrapImage(cfg *Config, buildHostIP string) (string, error) {
	if err := cfg.rsyncNix(buildHostIP); err != nil {
		return "", err
	}

	fmt.Println("Building DigitalOcean bootstrap image on build host (this can take a long time)...")
	remoteScript := fmt.Sprintf(`
set -euo pipefail
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
cd %s
rm -rf result
nix run nixpkgs#nixos-rebuild -- build-image \
  --flake .#bootstrap \
  --image-variant digital-ocean
img=$(find -L result -type f \( -name '*.qcow2.gz' -o -name '*.qcow2.bz2' \) | head -n1)
if [ -z "$img" ]; then
  echo "Could not find built DigitalOcean image under result/" >&2
  ls -laR result >&2 || true
  exit 1
fi
cp -L "$img" /root/nixos-do-dev.qcow2.gz
ls -lh /root/nixos-do-dev.qcow2.gz
`, remoteNixDir)
	if err := cfg.runSSH(buildHostIP, remoteScript); err != nil {
		return "", fmt.Errorf("remote image build: %w", err)
	}

	localImg := filepath.Join(cfg.StateDir, "nixos-do-dev.qcow2.gz")
	fmt.Printf("Copying image back to %s ...\n", localImg)
	if err := cfg.scpFrom(buildHostIP, "/root/nixos-do-dev.qcow2.gz", localImg); err != nil {
		return "", fmt.Errorf("scp image: %w", err)
	}
	return localImg, nil
}

func uploadSpaces(ctx context.Context, cfg *Config, localPath, objectKey string) error {
	f, err := os.Open(localPath)
	if err != nil {
		return err
	}
	defer f.Close()

	client := cfg.s3Client(ctx)
	_, err = client.PutObject(ctx, &s3.PutObjectInput{
		Bucket: aws.String(cfg.SpacesBucket),
		Key:    aws.String(objectKey),
		Body:   f,
		ACL:    types.ObjectCannedACLPublicRead,
	})
	return err
}

func deleteSpaces(ctx context.Context, cfg *Config, objectKey string) error {
	client := cfg.s3Client(ctx)
	_, err := client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(cfg.SpacesBucket),
		Key:    aws.String(objectKey),
	})
	return err
}

func deleteNamedImages(ctx context.Context, client *godo.Client, name string) error {
	opt := &godo.ListOptions{PerPage: 200}
	for {
		images, resp, err := client.Images.ListUser(ctx, opt)
		if err != nil {
			return err
		}
		for _, img := range images {
			if img.Name == name {
				fmt.Printf("Deleting existing custom image %s (%d)...\n", img.Name, img.ID)
				if _, err := client.Images.Delete(ctx, img.ID); err != nil {
					fmt.Printf("warning: delete image %d: %v\n", img.ID, err)
				}
			}
		}
		if resp.Links == nil || resp.Links.IsLastPage() {
			break
		}
		page, err := resp.Links.CurrentPage()
		if err != nil {
			break
		}
		opt.Page = page + 1
	}
	return nil
}

func waitImageAvailable(ctx context.Context, client *godo.Client, id int) (string, error) {
	deadline := time.Now().Add(60 * time.Minute)
	for time.Now().Before(deadline) {
		img, _, err := client.Images.GetByID(ctx, id)
		if err != nil {
			fmt.Printf("  image status: missing (%v)\n", err)
			select {
			case <-ctx.Done():
				return "", ctx.Err()
			case <-time.After(10 * time.Second):
			}
			continue
		}
		status := strings.ToLower(img.Status)
		fmt.Printf("  image status: %s\n", status)
		switch status {
		case "available":
			return status, nil
		case "deleted", "error":
			return status, fmt.Errorf("image upload failed (status=%s)", status)
		}
		select {
		case <-ctx.Done():
			return "", ctx.Err()
		case <-time.After(10 * time.Second):
		}
	}
	return "", fmt.Errorf("timed out waiting for image %d", id)
}
