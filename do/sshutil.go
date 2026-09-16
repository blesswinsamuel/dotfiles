package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

const remoteNixDir = "/root/do-nix"

func (c *Config) sshArgs(ip string, extra ...string) []string {
	args := append([]string{}, c.sshOpts()...)
	args = append(args, "root@"+ip)
	args = append(args, extra...)
	return args
}

func (c *Config) runSSH(ip string, remote string) error {
	cmd := exec.Command("ssh", c.sshArgs(ip, "bash", "-s")...)
	cmd.Stdin = strings.NewReader(remote)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func (c *Config) runSSHCheck(ip string, remote string) error {
	cmd := exec.Command("ssh", append(c.sshOpts(), "-o", "BatchMode=yes", "root@"+ip, remote)...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func (c *Config) waitSSH(ip string) error {
	fmt.Printf("Waiting for SSH on %s...\n", ip)
	deadline := time.Now().Add(5 * time.Minute)
	for time.Now().Before(deadline) {
		cmd := exec.Command("ssh", append(c.sshOpts(), "-o", "BatchMode=yes", "root@"+ip, "true")...)
		if err := cmd.Run(); err == nil {
			fmt.Println("SSH is up.")
			return nil
		}
		time.Sleep(5 * time.Second)
	}
	return fmt.Errorf("timed out waiting for SSH on %s", ip)
}

func (c *Config) ensureNix(ip string) error {
	fmt.Println("Ensuring Nix on build host...")
	script := `
set -euo pipefail
if ! command -v nix >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
nix --version
`
	return c.runSSH(ip, script)
}

func (c *Config) rsyncNix(ip string) error {
	if _, err := os.Stat(filepath.Join(c.NixDir, "flake.nix")); err != nil {
		return fmt.Errorf("bootstrap flake missing at %s: %w", c.NixDir, err)
	}
	fmt.Printf("Rsyncing minimal nix config %s → root@%s:%s ...\n", c.NixDir, ip, remoteNixDir)
	sshCmd := "ssh " + strings.Join(c.sshOpts(), " ")
	args := []string{
		"-az", "--delete",
		"--exclude", "result",
		"--exclude", ".git",
		"-e", sshCmd,
		c.NixDir + "/",
		fmt.Sprintf("root@%s:%s/", ip, remoteNixDir),
	}
	cmd := exec.Command("rsync", args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func (c *Config) interactiveSSH(ip string, extra []string) error {
	args := append(c.sshOpts(), "root@"+ip)
	args = append(args, extra...)
	cmd := exec.Command("ssh", args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
