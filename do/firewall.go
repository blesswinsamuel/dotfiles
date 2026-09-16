package main

import (
	"context"
	"fmt"
	"os"
	"strconv"

	"github.com/digitalocean/godo"
)

func blockPorts(ctx context.Context, cfg *Config) error {
	if err := cfg.requireToken(); err != nil {
		return err
	}
	if err := cfg.ensureStateDir(); err != nil {
		return err
	}
	host, err := loadHost(cfg.devHostPath())
	if err != nil {
		return fmt.Errorf("no dev host state; run: dev up")
	}
	dropletID, err := strconv.Atoi(host.ID)
	if err != nil {
		return err
	}

	fmt.Printf("Checking Tailscale on %s (%s) before locking public ports...\n", host.Name, host.IP)
	if err := cfg.runSSHCheck(host.IP, "command -v tailscale >/dev/null 2>&1 && tailscale status >/dev/null 2>&1"); err != nil {
		fmt.Fprintln(os.Stderr, "Tailscale is not up on the droplet.")
		fmt.Fprintln(os.Stderr, "SSH in first and run: sudo tailscale up")
		fmt.Fprintln(os.Stderr, "  task do:dev:ssh")
		return fmt.Errorf("tailscale not ready")
	}
	fmt.Println("Tailscale looks healthy.")

	client := cfg.doClient(ctx)
	inbound := []godo.InboundRule{{
		Protocol:  "udp",
		PortRange: "41641",
		Sources: &godo.Sources{
			Addresses: []string{"0.0.0.0/0", "::/0"},
		},
	}}
	outbound := []godo.OutboundRule{
		{Protocol: "tcp", PortRange: "all", Destinations: &godo.Destinations{Addresses: []string{"0.0.0.0/0", "::/0"}}},
		{Protocol: "udp", PortRange: "all", Destinations: &godo.Destinations{Addresses: []string{"0.0.0.0/0", "::/0"}}},
		{Protocol: "icmp", Destinations: &godo.Destinations{Addresses: []string{"0.0.0.0/0", "::/0"}}},
	}

	var firewallID string
	firewallName := cfg.FirewallName

	if existing, err := readJSON[FirewallState](cfg.firewallPath()); err == nil {
		if _, _, err := client.Firewalls.Get(ctx, existing.ID); err != nil {
			fmt.Printf("Stale firewall state (%s); creating a new firewall...\n", existing.ID)
			_ = os.Remove(cfg.firewallPath())
		} else {
			firewallID = existing.ID
			fmt.Printf("Updating existing firewall %s...\n", firewallID)
			req := &godo.FirewallRequest{
				Name:          firewallName,
				InboundRules:  inbound,
				OutboundRules: outbound,
				DropletIDs:    []int{dropletID},
			}
			if _, _, err := client.Firewalls.Update(ctx, firewallID, req); err != nil {
				return fmt.Errorf("update firewall: %w", err)
			}
		}
	}

	if firewallID == "" {
		fmt.Printf("Creating cloud firewall %s (UDP 41641 only inbound) for droplet %d...\n", firewallName, dropletID)
		fw, _, err := client.Firewalls.Create(ctx, &godo.FirewallRequest{
			Name:          firewallName,
			InboundRules:  inbound,
			OutboundRules: outbound,
			DropletIDs:    []int{dropletID},
		})
		if err != nil {
			return fmt.Errorf("create firewall: %w", err)
		}
		firewallID = fw.ID
		firewallName = fw.Name
	}

	st := FirewallState{
		ID:        firewallID,
		Name:      firewallName,
		DropletID: host.ID,
	}
	if err := writeJSON(cfg.firewallPath(), st); err != nil {
		return err
	}
	fmt.Printf("Firewall attached: %s (%s) → droplet %d\n", firewallName, firewallID, dropletID)
	fmt.Printf("State written to %s\n", cfg.firewallPath())
	fmt.Println()
	fmt.Println("Public inbound blocked except UDP 41641 (Tailscale direct).")
	fmt.Println("task do:dev:ssh (public IP) will no longer work — use Tailscale hostname/IP.")
	return nil
}

func unblockPorts(ctx context.Context, cfg *Config) error {
	if err := cfg.requireToken(); err != nil {
		return err
	}

	existing, err := readJSON[FirewallState](cfg.firewallPath())
	if err != nil {
		fmt.Println("No local firewall state — public ports are already unblocked (or never blocked).")
		return nil
	}

	client := cfg.doClient(ctx)
	fmt.Printf("Deleting cloud firewall %s (%s)...\n", existing.Name, existing.ID)
	if _, err := client.Firewalls.Delete(ctx, existing.ID); err != nil {
		return fmt.Errorf("delete firewall: %w", err)
	}
	_ = os.Remove(cfg.firewallPath())
	fmt.Println("Firewall removed — public SSH (TCP 22) and other inbound ports are open again.")
	fmt.Println("Re-lock later with: task do:dev:block-ports")
	return nil
}
