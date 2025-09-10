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
