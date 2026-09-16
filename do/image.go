package main

import (
	"context"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/digitalocean/godo"
)

const (
	remoteImageDir  = "/root/nixos-do-image"
	remoteImageFile = "nixos-do-dev.qcow2.gz"
	miniservePID    = "/tmp/nixos-image-http.pid"
)

func cmdImage(ctx context.Context, cfg *Config, args []string) error {
	if len(args) < 1 || args[0] != "build" {
		return fmt.Errorf("usage: image build [--teardown] [--force]")
	}
	teardown := false
	force := false
	for _, a := range args[1:] {
		switch a {
		case "--teardown":
			teardown = true
		case "--force":
			force = true
		}
	}
	if err := imageBuild(ctx, cfg, force); err != nil {
		return err
	}
	if teardown {
		fmt.Println("--teardown: destroying build host...")
		return buildHostDown(ctx, cfg)
	}
	fmt.Println("Build host left running. Destroy with: task do:build-host:down")
	return nil
}

func imageBuild(ctx context.Context, cfg *Config, force bool) error {
	if err := cfg.requireToken(); err != nil {
		return err
	}
	if err := cfg.ensureStateDir(); err != nil {
		return err
	}

	host, err := loadHost(cfg.buildHostPath())
	if err != nil {
		return fmt.Errorf("no build host state; run: build-host up")
	}

	client := cfg.doClient(ctx)
	imageURL := fmt.Sprintf("http://%s:%s/%s", host.IP, cfg.ImageHTTPPort, remoteImageFile)

	if !force {
		if existing, err := findNamedImage(ctx, client, cfg.ImageName); err == nil && existing != nil {
			status := strings.ToLower(existing.Status)
			switch status {
			case "available":
				fmt.Printf("Custom image %s (%d) already available — nothing to do.\n", existing.Name, existing.ID)
				return writeImageState(cfg, existing, host.Region, status, imageURL)
			case "pending", "new":
				fmt.Printf("Resuming wait for in-progress image %s (%d, status=%s)...\n", existing.Name, existing.ID, status)
				if err := cfg.waitSSH(host.IP); err != nil {
					return err
				}
				if err := cfg.ensureNix(host.IP); err != nil {
					return err
				}
				if ok, _ := remoteImageExists(cfg, host.IP); ok {
					if err := ensureMiniserve(cfg, host.IP); err != nil {
						return err
					}
					defer stopMiniserveQuiet(cfg, host.IP)
				} else {
					fmt.Println("warning: remote qcow2 missing; DO import may fail if it still needs to fetch")
				}
				final, err := waitImageAvailable(ctx, client, existing.ID)
				if err != nil {
					return err
				}
				return writeImageState(cfg, existing, host.Region, final, imageURL)
			}
		}
	}

	if err := cfg.waitSSH(host.IP); err != nil {
		return err
	}
	if err := cfg.ensureNix(host.IP); err != nil {
		return err
	}

	if !force {
		if ok, _ := remoteImageExists(cfg, host.IP); ok {
			fmt.Printf("Reusing existing %s/%s on build host (pass --force to rebuild).\n", remoteImageDir, remoteImageFile)
		} else {
			if err := buildBootstrapImage(cfg, host.IP); err != nil {
				return err
			}
		}
	} else {
		fmt.Println("--force: rebuilding bootstrap image...")
		if err := buildBootstrapImage(cfg, host.IP); err != nil {
			return err
		}
	}

	fmt.Printf("Serving image with miniserve on build host :%s ...\n", cfg.ImageHTTPPort)
	if err := ensureMiniserve(cfg, host.IP); err != nil {
		return err
	}
	defer stopMiniserveQuiet(cfg, host.IP)

	if force {
		if err := deleteNamedImages(ctx, client, cfg.ImageName); err != nil {
			fmt.Printf("warning: deleting existing images: %v\n", err)
		}
	} else if existing, err := findNamedImage(ctx, client, cfg.ImageName); err == nil && existing != nil {
		status := strings.ToLower(existing.Status)
		switch status {
		case "available":
			return writeImageState(cfg, existing, host.Region, status, imageURL)
		case "pending", "new":
			fmt.Printf("Waiting for existing image %d (status=%s)...\n", existing.ID, status)
			final, err := waitImageAvailable(ctx, client, existing.ID)
			if err != nil {
				return err
			}
			return writeImageState(cfg, existing, host.Region, final, imageURL)
		default:
			fmt.Printf("Deleting unusable existing image %s (%d, status=%s)...\n", existing.Name, existing.ID, status)
			if _, err := client.Images.Delete(ctx, existing.ID); err != nil {
				fmt.Printf("warning: delete image %d: %v\n", existing.ID, err)
			}
		}
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

	// Checkpoint so a crash mid-wait can resume.
	_ = writeImageState(cfg, created, host.Region, strings.ToLower(created.Status), imageURL)

	fmt.Printf("Waiting for custom image %d to become available...\n", created.ID)
	status, err := waitImageAvailable(ctx, client, created.ID)
	if err != nil {
		return err
	}
	return writeImageState(cfg, created, host.Region, status, imageURL)
}

func writeImageState(cfg *Config, img *godo.Image, region, status, url string) error {
	st := ImageState{
		ID:     strconv.Itoa(img.ID),
		Name:   img.Name,
		Region: region,
		Status: status,
		URL:    url,
	}
	if err := writeJSON(cfg.imagePath(), st); err != nil {
		return err
	}
	fmt.Printf("Custom image ready: %s (%d)\n", img.Name, img.ID)
	fmt.Printf("State written to %s\n", cfg.imagePath())
	fmt.Println("Next: task do:dev:up, then on the droplet: task switch (flake attr do-cloud-dev)")
	return nil
}

func buildBootstrapImage(cfg *Config, buildHostIP string) error {
	if err := cfg.rsyncNix(buildHostIP); err != nil {
		return err
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
rm -rf %s
mkdir -p %s
cp -L "$img" %s/%s
ls -lh %s/%s
`, remoteNixDir, remoteImageDir, remoteImageDir, remoteImageDir, remoteImageFile, remoteImageDir, remoteImageFile)
	if err := cfg.runSSH(buildHostIP, remoteScript); err != nil {
		return fmt.Errorf("remote image build: %w", err)
	}
	return nil
}

func remoteImageExists(cfg *Config, ip string) (bool, error) {
	err := cfg.runSSHCheck(ip, fmt.Sprintf("test -f %s/%s", remoteImageDir, remoteImageFile))
	return err == nil, err
}

func ensureMiniserve(cfg *Config, ip string) error {
	check := fmt.Sprintf(`curl -fsS -o /dev/null -I "http://127.0.0.1:%s/%s"`, cfg.ImageHTTPPort, remoteImageFile)
	if err := cfg.runSSHCheck(ip, check); err == nil {
		fmt.Println("miniserve already serving.")
		return nil
	}
	return startMiniserve(cfg, ip)
}

func startMiniserve(cfg *Config, ip string) error {
	script := fmt.Sprintf(`
set -euo pipefail
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
if [ -f %s ]; then
  kill "$(cat %s)" 2>/dev/null || true
  rm -f %s
fi
# Prefetch so the backgrounded server starts quickly.
nix build --no-link nixpkgs#miniserve
cd %s
nohup nix run nixpkgs#miniserve -- \
  --interfaces 0.0.0.0 \
  --port %s \
  --hide-version-footer \
  . >/tmp/nixos-image-http.log 2>&1 &
echo $! > %s
for i in $(seq 1 60); do
  if curl -fsS -o /dev/null -I "http://127.0.0.1:%s/%s"; then
    echo "miniserve is up."
    exit 0
  fi
  sleep 2
done
echo "miniserve failed to become ready; log:" >&2
cat /tmp/nixos-image-http.log >&2 || true
exit 1
`, miniservePID, miniservePID, miniservePID, remoteImageDir, cfg.ImageHTTPPort, miniservePID, cfg.ImageHTTPPort, remoteImageFile)
	return cfg.runSSH(ip, script)
}

func stopMiniserve(cfg *Config, ip string) error {
	script := fmt.Sprintf(`
set -euo pipefail
if [ -f %s ]; then
  kill "$(cat %s)" 2>/dev/null || true
  rm -f %s
fi
`, miniservePID, miniservePID, miniservePID)
	return cfg.runSSH(ip, script)
}

func stopMiniserveQuiet(cfg *Config, ip string) {
	fmt.Println("Stopping miniserve on build host...")
	_ = stopMiniserve(cfg, ip)
}

func findNamedImage(ctx context.Context, client *godo.Client, name string) (*godo.Image, error) {
	opt := &godo.ListOptions{PerPage: 200}
	for {
		images, resp, err := client.Images.ListUser(ctx, opt)
		if err != nil {
			return nil, err
		}
		for i := range images {
			if images[i].Name == name {
				return &images[i], nil
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
	return nil, nil
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
	start := time.Now()
	deadline := start.Add(60 * time.Minute)
	for time.Now().Before(deadline) {
		elapsed := time.Since(start).Truncate(time.Second)
		img, _, err := client.Images.GetByID(ctx, id)
		if err != nil {
			fmt.Printf("  [%s] image status: missing (%v)\n", elapsed, err)
			select {
			case <-ctx.Done():
				return "", ctx.Err()
			case <-time.After(10 * time.Second):
			}
			continue
		}
		status := strings.ToLower(img.Status)
		fmt.Printf("  [%s] image status: %s\n", elapsed, status)
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
	return "", fmt.Errorf("timed out waiting for image %d after %s", id, time.Since(start).Truncate(time.Second))
}
