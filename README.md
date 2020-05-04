# .files

## Install

```
git clone https://github.com/blesswinsamuel/dotfiles
cd dotfiles
./install.py [-n]
```

## Configurations

- fish
- vim
- tmux
- brew

## Brew

```sh
brew update
set -gx HOMEBREW_BUNDLE_CASK_SKIP "telegram philips-hue-sync transmission imageoptim graphql-playground intellij-idea fork istat-menus coconutbattery sequel-pro"
set -gx HOMEBREW_BUNDLE_MAS_SKIP "1037126344 409201541 409183694 409203825 634159523 497799835 1432731683 441258766 1287239339 829912893 801463932 1278508951 1482454543 1254743014 803453959"
brew bundle
brew bundle cleanup
brew bundle cleanup --zap --force
brew bundle check --verbose
```

## Set default shell

```sh
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)
```

## VS Code

```sh
# List
code --list-extensions > vs_code_extensions.txt
# Install
cat vs_code_extensions.txt | xargs -n 1 code --install-extension
```

### Create GPG Key
```
gpg --full-generate-key
# Use key size 4096
```

```
gpg --armor --export <email> | pbcopy
```
