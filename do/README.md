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
sudo tailscale up
git clone https://github.com/blesswinsamuel/dotfiles && cd dotfiles
mkdir -p ~/.config/dotfiles && echo do-cloud-dev > ~/.config/dotfiles/host-id
sudo nixos-rebuild switch --flake .#do-cloud-dev
# Dotfiles (`task run-home`) need secrets/`op` on the box if you want that too.

# 5) Public inbound: UDP 41641 only (Tailscale direct)
task do:dev:block-ports

# Tear down
task do:dev:down
task do:build-host:down
```

Or call the CLI directly:

```bash
go -C do run . build-host up
go -C do run . image build
go -C do run . image build --force
go -C do run . dev up
```

## Env (Taskfile defaults)

[`Taskfile.do.yaml`](../Taskfile.do.yaml) sets:

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
