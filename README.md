# .files

## Install

```bash
# https://github.com/DeterminateSystems/nix-installer
# https://zero-to-nix.com/start/install
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
# /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t

# nix flake init -t nix-darwin
# mv /etc/zshenv /etc/zshenv.before-nix-darwin
# mv /etc/shells /etc/shells.before-nix-darwin

nix run nixpkgs#go-task -- init # first run
nix run nixpkgs#go-task -- switch
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

## Resources

- https://xyno.space/post/nix-darwin-introduction
- https://devenv.sh/getting-started/
- https://sandstorm.de/de/blog/post/my-first-steps-with-nix-on-mac-osx-as-homebrew-replacement.html
- https://github.com/nix-community/impermanence
- https://github.com/schickling/dotfiles (https://www.youtube.com/watch?v=1dzgVkgQ5mE)
- https://github.com/badele/nix-homelab/tree/main
- https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled
