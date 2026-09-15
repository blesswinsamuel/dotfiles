# .files

## Install

```bash
# https://github.com/DeterminateSystems/nix-installer
# https://zero-to-nix.com/start/install
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

nix run nixpkgs#git clone https://github.com/blesswinsamuel/dotfiles
cd dotfiles

# Set logical host id (required; never commit this file)
task set-host-id -- mac-studio   # or work-laptop, hp-laptop, …

task secrets:unlock              # once per machine (decrypts age → local cache)
nix run nixpkgs#go-task -- darwin-init # first run (Mac)
# or: nix run nixpkgs#go-task -- init
nix run nixpkgs#go-task -- switch -- --verbose
```

## Install - NixOS

```bash
sudo nano /etc/nixos/configuration.nix
#  nix.settings.experimental-features = [ "nix-command" "flakes" ];
sudo nixos-rebuild switch

nix run nixpkgs#git clone https://github.com/blesswinsamuel/dotfiles
cd dotfiles
task set-host-id -- hp-laptop   # or hp-chromebox, do-cloud-dev, …
task secrets:unlock

nix run nixpkgs#go-task -- init # first run
```

## Install - Ubuntu (work-management-droplet)

NixOS cannot be installed on this host. Use the home tool (+ mise) only:

```bash
git clone https://github.com/blesswinsamuel/dotfiles
cd dotfiles
task set-host-id -- work-management-droplet
# Install mise + 1Password CLI; sign in to work account
task secrets:unlock
task run-home
```

See [hosts/work-management-droplet/README.md](hosts/work-management-droplet/README.md).

## Host identity

Repo configs use **logical host ids**, not OS hostnames/serials:

| Logical ID | Role |
| ---------- | ---- |
| `mac-studio` | Personal Mac (nix-darwin) |
| `work-laptop` | Work Mac (nix-darwin) |
| `hp-laptop` | Personal Linux laptop (NixOS) |
| `hp-chromebox` | Personal Linux desktop (NixOS) |
| `do-cloud-dev` | Personal DO cloud NixOS |
| `work-management-droplet` | Work Ubuntu droplet (home tool only) |

Identity comes from `~/.config/dotfiles/host-id` (one line, e.g. `mac-studio`). Missing or empty → fail with a clear error.

```bash
task set-host-id -- mac-studio
# or
mkdir -p ~/.config/dotfiles && echo mac-studio > ~/.config/dotfiles/host-id
```

NixOS hosts set `networking.hostName` to the same logical id. nix-darwin always uses `--flake .#$(host-id)` so work Mac serial names never need to live in git.

## Secrets (age)

Source of truth is [`config.yaml.age`](config.yaml.age) in the repo (git email, signing keys, Wakatime). Decrypt uses this machine’s SSH private key from 1Password; the Taskfile picks the item from host **realm** (`personal` → Personal SSH Key, `work` → Work SSH Key). Sign in to the matching 1Password account on that machine.

To avoid unlocking 1Password on every apply, decrypt once into a local cache:

```bash
task secrets:unlock   # writes ~/.config/dotfiles/secrets.yaml (mode 600)
task run-home         # uses the cache; auto-unlocks if missing
```

After `task edit-config`, the cache is refreshed via `secrets:unlock`. Force refresh anytime with `task secrets:unlock`.

## Architecture

This repo uses [nix-darwin](https://github.com/nix-darwin/nix-darwin) / NixOS for system packages, a custom Go tool for dotfiles, Homebrew Brewfiles for macOS GUI apps, and [mise](https://mise.jdx.dev/) for language/AI CLI runtimes. Home Manager was tried briefly (Jan–Aug 2024) and removed.

| Layer | Tool | Responsibility |
| ----- | ---- | ---------------- |
| System packages | [flake.nix](flake.nix) + commons modules | CLI tools, shells, fonts, OS services |
| Dotfiles | [home.yaml](home.yaml) + [main.go](main.go) | Symlink/copy configs; age secrets; dock / default apps |
| GUI / macOS apps | per-host `Brewfile` | Casks, taps, mas; `homebrew.enable = false` in [commons/darwin.nix](commons/darwin.nix) |
| Runtimes | [home/mise/config.toml](home/mise/config.toml) | Node, Go, Python, Terraform, AI CLIs, etc. |

`task switch` runs `darwin-rebuild`/`nixos-rebuild`, then `task run-home`. On `work-management-droplet`, use `task run-home` only (`task switch` has no flake attr and will fail).

### Profile / module layers

Merge order (home tool and Nix imports share this mental model):

1. `commons` — everything
2. `commons-darwin` / `commons-linux` — OS-only
3. `personal` / `work` — realm (secrets / identity)
4. `personal-darwin` / `personal-linux` / `work-darwin` / `work-linux`
5. `hosts.<logical-id>` — dock, Brewfile, host-only packages

Nix layout:

```text
commons/commons.nix
commons/darwin.nix
commons/linux.nix                 # NixOS desktop base (Plasma, users, …)
commons/personal-darwin.nix
commons/personal-linux.nix        # Tailscale on personal NixOS
commons/personal-linux-desktop.nix
commons/work-darwin.nix
commons/work-linux.nix
hosts/<logical-id>/
```

Personal NixOS hosts (`hp-laptop`, `hp-chromebox`, `do-cloud-dev`) enable Tailscale via `personal-linux`. One-time: `sudo tailscale up`.

### Why not Home Manager?

**Primary reason: slow iteration on dotfiles.** With Home Manager, shell and editor configs lived in Nix modules (`programs.zsh`, `programs.fish`, `programs.tmux`, etc.). Every tweak to a `.zshrc`-equivalent required a full `darwin-rebuild switch` / Nix build — too slow for day-to-day dotfile editing.

The current setup separates concerns:

- **Dotfiles** are plain files under `home/` (e.g. [home/zsh/zshrc](home/zsh/zshrc), [home/fish/config.fish](home/fish/config.fish)), symlinked into `$HOME` by `go run .`
- **Most edits are instant** — change the file in the repo and open a new shell; the symlink means `$HOME` sees it immediately, with no Nix rebuild
- **Nix rebuild only for system changes** — adding/removing packages, nix-darwin defaults, host modules
- **`task run-home` is cheap** — re-applies symlinks, templates, dock/prefs; not a Nix evaluation

Home Manager conflates "edit my shell config" with "rebuild my system"; this repo keeps those on separate paths.

Other reasons that contributed:

1. **Overlap with the custom home tool** — HM `programs.*` duplicated what `home.yaml` already symlinked; shell configs moved fully into `home.yaml` when HM was removed
2. **Shell integration friction** — HM-generated zsh/fish init caused double `compinit`, `NIX_PROFILES` fpath wiring, and [home-manager#177](https://github.com/nix-community/home-manager/issues/177) history-option ordering issues
3. **macOS extras in the Go tool** — dock (`dockutil`), default apps (`swda`), plist prefs — applied by `main.go`, not HM
4. **Secret templating, multi-path agent symlinks, Brewfile separation** — additional benefits of `home.yaml` + Go tool

**Tradeoffs:**

- No HM home generations / rollback for dotfiles
- Shell completions and program modules must be wired manually in dotfiles
- System changes still require a Nix rebuild; only dotfile edits are fast
- Two apply steps for a full sync (`darwin-rebuild` + `go run .`), but dotfile-only changes skip the rebuild entirely

## DigitalOcean NixOS (dev)

Minimal headless NixOS image for DigitalOcean, plus Taskfile helpers that use `doctl`. Flake attr: `do-cloud-dev`.

**Prereqs:** `doctl` (`doctl auth init`), `jq`, `rsync`, and a DO SSH key fingerprint/ID:

```bash
doctl compute ssh-key list
export DO_SSH_KEY='<fingerprint-or-id>'
```

Optional env vars: `DO_REGION` (default `nyc3`), `DO_BUILD_SIZE` (default `s-4vcpu-8gb`), `DO_DEV_SIZE` (default `s-2vcpu-4gb`), `DO_IMAGE_NAME` (default `nixos-do-dev`).

```bash
# 1) Ephemeral Ubuntu builder (IP/id written to .local/do/build-host.json)
task do:build-host:up

# 2) Build digital-ocean image on the builder, upload as a custom image
task do:image:build
# or build + destroy the builder when done:
task do:image:build-and-teardown

# 3) Provision a lasting dev droplet from the custom image
task do:dev:up
task do:dev:ssh

# Tear down
task do:dev:down
task do:build-host:down   # if still running
```

State under `.local/do/` is gitignored. Image builds on DO droplets are slow (no nested KVM / QEMU TCG).

## Brew commands

```bash
brew update
brew bundle --global
brew bundle --global cleanup
brew bundle --global cleanup --zap --force
brew bundle --global check --verbose
```

### GPG key first time setup

```bash
gpg --full-generate-key # Use key size 4096
# Export key
gpg --armor --export <email> | pbcopy
```

### SSH key first time setup

```bash
ssh-keygen -t ed25519
```

## Mackup

```bash
cat <<EOF > ~/.config/rclone/rclone.conf 
[b2]
type = b2
account = 
key = 
EOF
mackup backup # --dry-run
rclone sync ~/Mackup b2:blesswin-mackup # --dry-run
rclone ls b2:blesswin-mackup

rclone sync b2:blesswin-mackup ~/Mackup # --dry-run
mackup restore # --dry-run
```

## Mac manual steps

- Settings -> Keyboard -> Keyboard Shortcuts -> Modifier Keys -> Change Caps Lock to Escape
- Settings -> Keyboard -> Keyboard Shortcuts -> Spotlight -> Show Spotlight Search -> Change to Ctrl+Cmd+Option+space
- iTerm2
    - Keys -> Hotkey -> Command+Esc
    - Profiles -> Keys -> Presets -> Natural Text Editing

## Resources

- https://xyno.space/post/nix-darwin-introduction
- https://devenv.sh/getting-started/
- https://sandstorm.de/de/blog/post/my-first-steps-with-nix-on-mac-osx-as-homebrew-replacement.html
- https://github.com/nix-community/impermanence
- https://github.com/schickling/dotfiles (https://www.youtube.com/watch?v=1dzgVkgQ5mE)
- https://github.com/badele/nix-homelab/tree/main
- https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled
- https://github.com/ironicbadger/nix-config
- https://github.com/dustinlyons/nixos-config
- https://wickedchicken.github.io/post/macos-nix-setup/
- https://www.mathiaspolligkeit.com/dev-environment-setup-with-nix-on-macos/
- https://github.com/kubukoz/nix-config
- https://github.com/malob/nixpkgs
- https://github.com/ryan4yin/nix-config
