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
	awscreds "github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/digitalocean/godo"
	"golang.org/x/oauth2"
)

type Config struct {
	RepoDir    string
	NixDir     string
	StateDir   string
	KnownHosts string

	DOToken  string
	DORegion string
	DOSSHKey string

	BuildName    string
	BuildSize    string
	BuildImage   string
	DevName      string
	DevSize      string
	ImageName    string
	FirewallName string

	SpacesBucket   string
	SpacesRegion   string
	SpacesKey      string
	SpacesSecret   string
	SpacesEndpoint string
}

func loadConfig() (*Config, error) {
	repoDir, err := findRepoDir()
	if err != nil {
		return nil, err
	}

	stateDir := filepath.Join(repoDir, ".local", "do")
	cfg := &Config{
		RepoDir:        repoDir,
		NixDir:         filepath.Join(repoDir, "do", "nix"),
		StateDir:       stateDir,
		KnownHosts:     filepath.Join(stateDir, "known_hosts"),
		DOToken:        env("DIGITALOCEAN_ACCESS_TOKEN", env("DO_TOKEN", "")),
		DORegion:       env("DO_REGION", "blr1"),
		DOSSHKey:       env("DO_SSH_KEY", ""),
		BuildName:      env("DO_BUILD_NAME", "nixos-build"),
		BuildSize:      env("DO_BUILD_SIZE", "s-4vcpu-8gb"),
		BuildImage:     env("DO_BUILD_IMAGE", "ubuntu-24-04-x64"),
		DevName:        env("DO_DEV_NAME", "nixos-dev"),
		DevSize:        env("DO_DEV_SIZE", "s-4vcpu-8gb"),
		ImageName:      env("DO_IMAGE_NAME", "nixos-do-dev"),
		FirewallName:   env("DO_FIREWALL_NAME", "nixos-dev-tailscale-only"),
		SpacesBucket:   env("SPACES_BUCKET", ""),
		SpacesRegion:   env("SPACES_REGION", "sgp1"),
		SpacesKey:      env("SPACES_KEY", ""),
		SpacesSecret:   env("SPACES_SECRET", ""),
		SpacesEndpoint: env("SPACES_ENDPOINT", ""),
	}
	if cfg.SpacesEndpoint == "" {
		cfg.SpacesEndpoint = fmt.Sprintf("https://%s.digitaloceanspaces.com", cfg.SpacesRegion)
	}
	return cfg, nil
}

// findRepoDir walks up until it finds do/nix/flake.nix (the bootstrap flake).
func findRepoDir() (string, error) {
	wd, err := os.Getwd()
	if err != nil {
		return "", err
	}
	dir := wd
	for {
		candidate := filepath.Join(dir, "do", "nix", "flake.nix")
		if _, err := os.Stat(candidate); err == nil {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", fmt.Errorf("could not find do/nix/flake.nix above %s", wd)
		}
		dir = parent
	}
}

func env(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func (c *Config) requireToken() error {
	if c.DOToken == "" {
		return fmt.Errorf("set DIGITALOCEAN_ACCESS_TOKEN (or DO_TOKEN)")
	}
	return nil
}

func (c *Config) requireSSHKey() error {
	if c.DOSSHKey == "" {
		return fmt.Errorf("set DO_SSH_KEY to a DigitalOcean SSH key fingerprint or ID")
	}
	return nil
}

func (c *Config) requireSpaces() error {
	if c.SpacesBucket == "" || c.SpacesKey == "" || c.SpacesSecret == "" {
		return fmt.Errorf("SPACES_BUCKET, SPACES_KEY, and SPACES_SECRET are required")
	}
	return nil
}

func (c *Config) ensureStateDir() error {
	return os.MkdirAll(c.StateDir, 0o755)
}

func (c *Config) doClient(ctx context.Context) *godo.Client {
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: c.DOToken})
	return godo.NewClient(oauth2.NewClient(ctx, ts))
}

func (c *Config) s3Client(ctx context.Context) *s3.Client {
	_ = ctx
	creds := awscreds.NewStaticCredentialsProvider(c.SpacesKey, c.SpacesSecret, "")
	return s3.New(s3.Options{
		Region:       c.SpacesRegion,
		Credentials:  creds,
		BaseEndpoint: aws.String(c.SpacesEndpoint),
	})
}

func (c *Config) spacesPublicURL(objectKey string) string {
	return fmt.Sprintf("https://%s.%s.digitaloceanspaces.com/%s", c.SpacesBucket, c.SpacesRegion, objectKey)
}

func (c *Config) sshOpts() []string {
	return []string{
		"-o", "StrictHostKeyChecking=accept-new",
		"-o", "UserKnownHostsFile=" + c.KnownHosts,
		"-o", "ConnectTimeout=10",
	}
}

func waitReady(ctx context.Context, client *godo.Client, id int) (*godo.Droplet, error) {
	deadline := time.Now().Add(10 * time.Minute)
	for time.Now().Before(deadline) {
		d, _, err := client.Droplets.Get(ctx, id)
		if err != nil {
			return nil, err
		}
		if d.Status == "active" {
			return d, nil
		}
		select {
		case <-ctx.Done():
			return nil, ctx.Err()
		case <-time.After(5 * time.Second):
		}
	}
	return nil, fmt.Errorf("timed out waiting for droplet %d", id)
}

func publicIPv4(d *godo.Droplet) (string, error) {
	for _, net := range d.Networks.V4 {
		if net.Type == "public" {
			return net.IPAddress, nil
		}
	}
	return "", fmt.Errorf("droplet %d has no public IPv4", d.ID)
}

func dropletSSHKeys(key string) ([]godo.DropletCreateSSHKey, error) {
	key = strings.TrimSpace(key)
	if key == "" {
		return nil, fmt.Errorf("empty DO_SSH_KEY")
	}
	if id, err := strconv.Atoi(key); err == nil {
		return []godo.DropletCreateSSHKey{{ID: id}}, nil
	}
	return []godo.DropletCreateSSHKey{{Fingerprint: key}}, nil
}
