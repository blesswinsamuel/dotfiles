# .files

## Install

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/blesswinsamuel/dotfiles/master/install.sh)"
```

## Configurations

- fish
- vim
- tmux
- brew

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
mackup backup
cat <<EOF > ~/.config/rclone/rclone.conf 
[b2]
type = b2
account = 
key = 
EOF
rclone sync ~/Mackup b2:blesswin-mackup # --dry-run
rclone ls b2:blesswin-mackup
```
