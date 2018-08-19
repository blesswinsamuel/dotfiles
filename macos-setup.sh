# Change screenshot location
defaults write com.apple.screencapture location ~/Documents/Screenshots

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles YES


# Dock spacer
# defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'

# Autohide dock
defaults write com.apple.Dock showhidden -bool TRUE

killall Finder
killall Dock
killall SystemUIServer

