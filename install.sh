#!/bin/bash -xe

export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/opt/homebrew/bin"

export HOMEBREW_BUNDLE_NO_LOCK=true

if [[ "$OSTYPE" =~ ^darwin.* ]]; then
    if ! command -v brew &> /dev/null; then
        # Install Homebrew - https://brew.sh
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
fi

DOTFILES_DIR=${DOTFILES_DIR:-~/dotfiles}
echo "dotfiles directory: $DOTFILES_DIR"

if [ ! -d "$DOTFILES_DIR" ]; then
    mkdir -p "${DOTFILES_DIR##*/}"
    git clone https://github.com/blesswinsamuel/dotfiles "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

if [[ "$OSTYPE" =~ ^darwin.* ]]; then
    export HOMEBREW_NO_AUTO_UPDATE=1
    brew update
    brew bundle install --file brewfiles/core.Brewfile.rb
fi

if ! command -v ansible &> /dev/null; then
    pipx install ansible --include-deps
fi

# ansible-playbook playbook.yml --extra-vars "ansible_sudo_pass=pass" -vC
if [[ "$ASK_BECOME_PASS" == "false" ]]; then
    ansible-playbook playbook.yml -v -e "ansible_sudo_pass=$ANSIBLE_SUDO_PASS"
else
    ansible-playbook playbook.yml --ask-become-pass -v
fi

if [[ "$OSTYPE" =~ ^darwin.* ]]; then
    brew bundle install --file brewfiles/core-addons.Brewfile.rb
    brew bundle install --file brewfiles/casks.Brewfile.rb
    brew bundle install --file brewfiles/mas.Brewfile.rb
    brew bundle install --file brewfiles/services.Brewfile.rb
    # brew bundle cleanup
    # brew bundle cleanup --zap --force
    cat brewfiles/*.Brewfile.rb | brew bundle check --verbose --file=-
fi

if [[ "$OSTYPE" =~ ^darwin.* ]]; then
    # mackup restore
    echo 'TODO'
fi

if [[ "$OSTYPE" =~ ^darwin.* ]]; then
    ### iTerm2
    ## Specify the preferences directory
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/configs/iterm2"
    ## Tell iTerm2 to use the custom preferences in the directory
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

    ### macOS
    sh "$DOTFILES_DIR/macos.sh"
fi
