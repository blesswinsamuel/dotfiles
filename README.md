# .files

## Install

```
git clone https://github.com/blesswinsamuel/dotfiles
cd dotfiles
ansible-playbook playbook.yml --extra-vars "ansible_sudo_pass=pass" -vC
ansible-playbook playbook.yml --ask-become-pass -vC
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

### Create GPG Key

```
gpg --full-generate-key
# Use key size 4096
```

```
gpg --armor --export <email> | pbcopy
```
