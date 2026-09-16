# DigitalOcean NixOS tooling

Go CLI + Taskfile helpers to build a minimal NixOS custom image on an ephemeral
Ubuntu droplet, then boot a lasting dev droplet and converge with the full flake.

## Layout

| Path | Purpose |
| --- | --- |
| [`nix/`](nix/) | Minimal bootstrap flake (SSH, flakes, Tailscale) — only this is rsynced to the builder |
| `*.go` / `go.mod` | Separate Go module (`go -C do run . …`) using [godo](https://github.com/digitalocean/godo) |
| [`../Taskfile.do.yaml`](../Taskfile.do.yaml) | Thin `task do:*` wrappers |

After boot, SSH in, `git clone` the full repo, and
`sudo nixos-rebuild switch --flake .#do-cloud-dev` (local `task switch` on your
Mac only rebuilds the Mac). First full switch on the droplet is slow (no KVM).

## Prerequisites

- Go, `rsync`, `ssh`
- [1Password CLI](https://developer.1password.com/docs/cli) (`op`) signed in to **personal** account `my.1password.com`
- DigitalOcean SSH key already uploaded to the account (fingerprint is set in the Taskfile)

## Quick start

From the **repo root**:

```bash
# 1) Ephemeral Ubuntu builder (.local/do/build-host.json)
task do:build-host:up

# 2) Build bootstrap image → serve with miniserve → register DO custom image
task do:image:build
# resumable: re-run to skip an existing qcow2 / pending import
# force rebuild: task do:image:build -- --force
# also destroy builder when done: task do:image:build-and-teardown

# 3) Lasting dev droplet from the custom image
task do:dev:up
task do:dev:ssh

# 4) On the droplet: Tailscale, then clone the full repo and switch
#    (bootstrap only has a slim image; this pulls in do-cloud-dev / commons)
#    set-host-id / switch do not need op; only Mac-side task do:* does
sudo tailscale up
git clone https://github.com/blesswinsamuel/dotfiles && cd dotfiles
nix run nixpkgs#go-task -- set-host-id -- do-cloud-dev
# optional: install 1Password CLI, then task secrets:unlock
nix run nixpkgs#go-task -- switch

# 5) Public inbound: UDP 41641 only (Tailscale direct)
task do:dev:block-ports
# reopen public SSH if needed:
# task do:dev:unblock-ports

# Tear down
task do:dev:down
task do:build-host:down
```

### Tailscale SSH: `Connection refused`

If `ssh` to the Tailscale IP fails with `Connection refused` but `tailscale ping` works and public SSH still works, check for a **route steal** by Twingate (or another VPN using CGNAT `100.x`).

Twingate often installs `100.96/12` on its `utun`, which is more specific than Tailscale’s `100.64/10`. Any Tailscale node in `100.96.0.0–100.111.255.255` (e.g. `100.108.x.x`) is then sent to Twingate and RSTs.

```bash
route get <tailscale-ip>   # bad: utun for Twingate / 100.96/12
                           # good: Tailscale utun / 100.64/10 host route
```

Fix: disconnect Twingate, or pin the host back to Tailscale’s interface:

```bash
sudo route add -host <tailscale-ip> -interface <tailscale-utun>   # e.g. utun5
```

Or call the CLI directly:

```bash
go -C do run . build-host up
go -C do run . image build
go -C do run . image build --force
go -C do run . dev up
```

## Env (Taskfile defaults)

[`Taskfile.do.yaml`](../Taskfile.do.yaml) sets these on each `do:*` task only (not globally):

| Variable | Source |
| --- | --- |
| `DIGITALOCEAN_ACCESS_TOKEN` | `op read --account my.1password.com "op://Dev/DigitalOcean Personal Access Token/credential"` |
| `DO_SSH_KEY` | personal SSH key fingerprint |
| `DO_REGION` | `blr1` |

Optional overrides: `DO_BUILD_SIZE`, `DO_DEV_SIZE`, `DO_IMAGE_NAME`, `IMAGE_HTTP_PORT` (default `8765`).

## How image build works

1. Rsync `do/nix` to the builder
2. On the builder: `nixos-rebuild build-image` for `.#bootstrap`
3. Serve the qcow2 with `nix run nixpkgs#miniserve`
4. Create a DO custom image from `http://<builder-ip>:8765/nixos-do-dev.qcow2.gz`
5. Poll until status is `available` (prints elapsed time), then stop miniserve

**Resume:** re-running `image build` reuses a remote qcow2 if present and continues waiting on a `pending`/`new` custom image. Use `--force` to rebuild and recreate.

State lives under `.local/do/` (gitignored). Builds on DO droplets are slow (no nested KVM).

## Remote desktop (XFCE default; Hyprland optional)

After a full `task switch` / `nixos-rebuild switch --flake .#do-cloud-dev`, the droplet auto-logs into **XFCE** (includes **1Password** CLI + GUI). Remoting is **Tailscale-only** (keep `task do:dev:block-ports`); do not open these ports on the DO cloud firewall.

To switch back to Hyprland + Quickshell + wayvnc later, set `desktop = "hyprland";` in [`hosts/do-cloud-dev/desktop-remote.nix`](../hosts/do-cloud-dev/desktop-remote.nix) and rebuild. Desktop-specific config lives in `desktop-xfce.nix` / `desktop-hyprland.nix`.

| Protocol | Client (Mac) | Connect |
| --- | --- | --- |
| Sunshine (best latency) | [Moonlight](https://moonlight-stream.org/) | Tailscale IP / hostname; open `https://<tailscale-ip>:47990` once to set credentials, then pair with PIN |
| RustDesk | RustDesk (Brewfile on mac-studio) | **Direct IP** → Tailscale IP (port **21118**). No ID/relay. |
| VNC (fallback) | Screen Sharing / TigerVNC | `vnc://<tailscale-ip>` — XFCE uses x11vnc; password in `~/.vnc/password.txt` |

Latency preference: Sunshine → RustDesk (direct) → VNC. Prefer a Tailscale **direct** path (`tailscale status`); DERP relay adds lag. DO has no GPU, so Sunshine uses CPU encode.

### VNC password

- **XFCE (default):** generated once into `~/.vnc/password.txt` (and `~/.vnc/passwd`). Show with `cat ~/.vnc/password.txt`.
- **Hyprland:** wayvnc macOS DES auth in `~/.config/wayvnc/config` (`rg '^password=' ~/.config/wayvnc/config`).

### RustDesk (no relay)

Host config seeds direct-IP mode and points rendezvous/relay at `127.0.0.1` (see `hosts/do-cloud-dev/config/rustdesk/`). After first graphical login, set a permanent password on the droplet:

```bash
rustdesk --password 'your-secret'
```

From Mac RustDesk, put the droplet Tailscale IP in the connect field (not the public ID). Traffic stays inside Tailscale; no `hbbs`/`hbbr`.

### Checks on the droplet

```bash
systemctl status display-manager   # LightDM when XFCE
systemctl --user status sunshine x11vnc rustdesk
# or, if desktop = "hyprland":
# systemctl status greetd
# systemctl --user status sunshine wayvnc rustdesk
```
