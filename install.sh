#!/bin/bash

export PATH="$PATH:$HOME/.local/bin"

if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v brew &> /dev/null; then
        # Install Homebrew - https://brew.sh
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    if ! command -v pipx &> /dev/null; then
        brew install pipx
    fi
    if ! command -v ansible &> /dev/null; then
        pipx install ansible --include-deps
    fi
fi

DOTFILES_DIR=~/Projects/blesswinsamuel/dotfiles

if [ ! -d "$DOTFILES_DIR" ]; then
    mkdir -p "${DOTFILES_DIR##*/}"
    git clone https://github.com/blesswinsamuel/dotfiles "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

# ansible-playbook playbook.yml --extra-vars "ansible_sudo_pass=pass" -vC
ansible-playbook playbook.yml --ask-become-pass -v
