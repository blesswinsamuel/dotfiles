package main

import (
	"context"
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/digitalocean/godo"
)

func cmdBuildHost(ctx context.Context, cfg *Config, args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: build-host up|down|ssh")
	}
	switch args[0] {
	case "up":
		return buildHostUp(ctx, cfg)
	case "down":
		return buildHostDown(ctx, cfg)
	case "ssh":
		return hostSSH(cfg, cfg.buildHostPath(), args[1:])
	default:
		return fmt.Errorf("unknown build-host command: %s", args[0])
	}
}

func cmdDev(ctx context.Context, cfg *Config, args []string) error {
	if len(args) < 1 {
		return fmt.Errorf("usage: dev up|down|ssh|block-ports|unblock-ports")
	}
	switch args[0] {
	case "up":
		return devUp(ctx, cfg)
	case "down":
		return devDown(ctx, cfg)
	case "ssh":
		return hostSSH(cfg, cfg.devHostPath(), args[1:])
	case "block-ports":
		return blockPorts(ctx, cfg)
	case "unblock-ports":
		return unblockPorts(ctx, cfg)
	default:
		return fmt.Errorf("unknown dev command: %s", args[0])
	}
}

func hostSSH(cfg *Config, statePath string, extra []string) error {
	h, err := loadHost(statePath)
	if err != nil {
		return err
	}
	return cfg.interactiveSSH(h.IP, extra)
}

func buildHostUp(ctx context.Context, cfg *Config) error {
	if err := cfg.requireToken(); err != nil {
		return err
	}
	if err := cfg.requireSSHKey(); err != nil {
		return err
	}
	if err := cfg.ensureStateDir(); err != nil {
		return err
	}
	if _, err := os.Stat(cfg.buildHostPath()); err == nil {
		return fmt.Errorf("build host state already exists at %s; run: build-host down", cfg.buildHostPath())
	}

	client := cfg.doClient(ctx)
	keys, err := dropletSSHKeys(cfg.DOSSHKey)
	if err != nil {
		return err
	}

	fmt.Printf("Creating build droplet %s in %s (%s)...\n", cfg.BuildName, cfg.DORegion, cfg.BuildSize)
	create, _, err := client.Droplets.Create(ctx, &godo.DropletCreateRequest{
		Name:   cfg.BuildName,
		Region: cfg.DORegion,
		Size:   cfg.BuildSize,
		Image: godo.DropletCreateImage{
			Slug: cfg.BuildImage,
		},
		SSHKeys: keys,
		Tags:    []string{"nixos-build"},
	})
	if err != nil {
		return fmt.Errorf("create droplet: %w", err)
	}

	d, err := waitReady(ctx, client, create.ID)
	if err != nil {
		return err
	}
	ip, err := publicIPv4(d)
	if err != nil {
		return err
	}

	st := HostState{
		ID:     strconv.Itoa(d.ID),
		Name:   d.Name,
		IP:     ip,
		Region: d.Region.Slug,
		Status: d.Status,
		Size:   cfg.BuildSize,
	}
	if err := writeJSON(cfg.buildHostPath(), st); err != nil {
		return err
	}
	fmt.Printf("Build host ready: %s (id=%d)\n", ip, d.ID)
	fmt.Printf("State written to %s\n", cfg.buildHostPath())
	return nil
}

func buildHostDown(ctx context.Context, cfg *Config) error {
	if err := cfg.requireToken(); err != nil {
		return err
	}
	h, err := loadHost(cfg.buildHostPath())
	if err != nil {
		fmt.Printf("No build host state at %s\n", cfg.buildHostPath())
		return nil
	}
	id, err := strconv.Atoi(h.ID)
	if err != nil {
		return err
	}
	fmt.Printf("Destroying build droplet %s (%s)...\n", h.Name, h.ID)
	if _, err := cfg.doClient(ctx).Droplets.Delete(ctx, id); err != nil {
		return err
	}
	_ = os.Remove(cfg.buildHostPath())
	fmt.Println("Build host destroyed.")
	return nil
}

func devUp(ctx context.Context, cfg *Config) error {
	if err := cfg.requireToken(); err != nil {
		return err
	}
	if err := cfg.requireSSHKey(); err != nil {
		return err
	}
	if err := cfg.ensureStateDir(); err != nil {
		return err
	}
	if _, err := os.Stat(cfg.devHostPath()); err == nil {
		return fmt.Errorf("dev host state already exists at %s; run: dev down", cfg.devHostPath())
	}
	img, err := readJSON[ImageState](cfg.imagePath())
	if err != nil {
		return fmt.Errorf("no image state at %s; run: image build", cfg.imagePath())
	}

	region := img.Region
	if r := strings.TrimSpace(os.Getenv("DO_REGION")); r != "" {
		region = r
	}
	imageID, err := strconv.Atoi(img.ID)
	if err != nil {
		return fmt.Errorf("invalid image id %q: %w", img.ID, err)
	}
	keys, err := dropletSSHKeys(cfg.DOSSHKey)
	if err != nil {
		return err
	}

	fmt.Printf("Creating dev droplet %s from image %d in %s...\n", cfg.DevName, imageID, region)
	client := cfg.doClient(ctx)
	create, _, err := client.Droplets.Create(ctx, &godo.DropletCreateRequest{
		Name:   cfg.DevName,
		Region: region,
		Size:   cfg.DevSize,
		Image: godo.DropletCreateImage{
			ID: imageID,
		},
		SSHKeys: keys,
		Tags:    []string{"nixos-dev"},
	})
	if err != nil {
		return fmt.Errorf("create droplet: %w", err)
	}
	d, err := waitReady(ctx, client, create.ID)
	if err != nil {
		return err
	}
	ip, err := publicIPv4(d)
	if err != nil {
		return err
	}

	st := HostState{
		ID:      strconv.Itoa(d.ID),
		Name:    d.Name,
		IP:      ip,
		Region:  d.Region.Slug,
		Status:  d.Status,
		Size:    cfg.DevSize,
		ImageID: img.ID,
	}
	if err := writeJSON(cfg.devHostPath(), st); err != nil {
		return err
	}
	fmt.Printf("Dev host ready: %s (id=%d)\n", ip, d.ID)
	fmt.Printf("State written to %s\n", cfg.devHostPath())
	fmt.Println("SSH: task do:dev:ssh")
	return nil
}

func devDown(ctx context.Context, cfg *Config) error {
	if err := cfg.requireToken(); err != nil {
		return err
	}
	client := cfg.doClient(ctx)

	if h, err := loadHost(cfg.devHostPath()); err == nil {
		id, err := strconv.Atoi(h.ID)
		if err != nil {
			return err
		}
		fmt.Printf("Destroying dev droplet %s (%s)...\n", h.Name, h.ID)
		if _, err := client.Droplets.Delete(ctx, id); err != nil {
			return err
		}
		_ = os.Remove(cfg.devHostPath())
		fmt.Println("Dev host destroyed.")
	} else {
		fmt.Printf("No dev host state at %s\n", cfg.devHostPath())
	}

	if fw, err := readJSON[FirewallState](cfg.firewallPath()); err == nil {
		fmt.Printf("Deleting cloud firewall %s (%s)...\n", fw.Name, fw.ID)
		if _, err := client.Firewalls.Delete(ctx, fw.ID); err != nil {
			fmt.Printf("warning: firewall delete: %v\n", err)
		}
		_ = os.Remove(cfg.firewallPath())
		fmt.Println("Firewall removed.")
	}
	return nil
}
