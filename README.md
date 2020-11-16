# .files

## Install

```bash
./install.sh
```

## Configurations

- fish
- vim
- tmux
- brew

## Brew

```sh
brew update
export HOMEBREW_BUNDLE_CASK_SKIP="telegram philips-hue-sync transmission imageoptim graphql-playground intellij-idea fork istat-menus coconutbattery sequel-pro"
export HOMEBREW_BUNDLE_MAS_SKIP="1037126344 409201541 409183694 409203825 634159523 497799835 1432731683 441258766 1287239339 829912893 801463932 1278508951 1482454543 1254743014 803453959"
brew bundle --global
brew bundle --global cleanup
brew bundle --global cleanup --zap --force
brew bundle --global check --verbose
```

### GPG Key first time setup

```
gpg --full-generate-key
# Use key size 4096
```

Export key

```
gpg --armor --export <email> | pbcopy
```
