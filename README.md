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
