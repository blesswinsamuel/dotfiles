#!/usr/bin/env bash

# Install all homebrew packages inside Brewfile
# Check for Homebrew Installation
if ! which brew > /dev/null; then
     # Install Homebrew
     /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update Homebrew
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install everything inside Brewfile
brew bundle

# Remove outdated versions from the cellar.
brew cleanup
