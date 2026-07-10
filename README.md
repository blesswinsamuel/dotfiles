# .files

## Install

```bash
# https://github.com/DeterminateSystems/nix-installer
# https://zero-to-nix.com/start/install
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

nix run nixpkgs#git clone https://github.com/blesswinsamuel/dotfiles

# printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
# /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t

# nix flake init -t nix-darwin
# mv /etc/zshenv /etc/zshenv.before-nix-darwin
# mv /etc/shells /etc/shells.before-nix-darwin

nix run nixpkgs#go-task -- darwin-init # first run
nix run nixpkgs#go-task -- switch -- --verbose

nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
nix-channel --update nixpkgs
```

## Install - NixOS

```bash
sudo nano /etc/nixos/configuration.nix
#  nix.settings.experimental-features = [ "nix-command" "flakes" ];
sudo nixos-rebuild switch

nix run nixpkgs#git clone https://github.com/blesswinsamuel/dotfiles

nix run nixpkgs#go-task -- init # first run
```

## Architecture

This repo uses [nix-darwin](https://github.com/nix-darwin/nix-darwin) / NixOS for system packages, a custom Go tool for dotfiles, and Homebrew Brewfiles for macOS GUI apps. Home Manager was tried briefly (Jan–Aug 2024) and removed.

| Layer | Tool | Responsibility |
| ----- | ---- | ---------------- |
| System packages | [flake.nix](flake.nix) + [commons/commons.nix](commons/commons.nix) | CLI tools, shells, fonts via `users.users.<name>.packages` and `environment.systemPackages` |
| Dotfiles | [home.yaml](home.yaml) + [main.go](main.go) | Symlink/copy configs into `$HOME`; age-templated secrets; macOS dock and default apps |
| GUI / macOS apps | per-host `Brewfile` (symlinked by `home.yaml`) | Casks, taps, mas; `homebrew.enable = false` in [commons/darwin-commons.nix](commons/darwin-commons.nix) |

`task switch` runs `darwin-rebuild`/`nixos-rebuild`, then `task run-home` (see [Taskfile.yaml](Taskfile.yaml)).

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
