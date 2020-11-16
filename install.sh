#!/bin/bash

export PATH="$PATH:$HOME/.local/bin"

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v brew &> /dev/null; then
        # Install Homebrew - https://brew.sh
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
fi

DOTFILES_DIR=~/Projects/blesswinsamuel/dotfiles

if [ ! -d "$DOTFILES_DIR" ]; then
    mkdir -p "${DOTFILES_DIR##*/}"
    git clone https://github.com/blesswinsamuel/dotfiles "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

if [[ "$OSTYPE" == "darwin"* ]]; then
    brew update
    brew bundle install
    brew bundle cleanup
    # brew bundle cleanup --zap --force
    brew bundle check --verbose
fi

if ! command -v ansible &> /dev/null; then
    pipx install ansible --include-deps
fi

# ansible-playbook playbook.yml --extra-vars "ansible_sudo_pass=pass" -vC
ansible-playbook playbook.yml --ask-become-pass -v
