#!/usr/bin/env bash

# ~/.macos — https://mths.be/macos

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Change screenshot location
# defaults read ~/Library/Preferences/com.apple.screencapture.plist
defaults write com.apple.screencapture location ~/Documents/Screenshots
# Alternative method: Cmd + Shift + 5 -> Options -> Save to Other location -> ~/Documents/Screenshots

# defaults read ~/Library/Preferences/com.apple.menuextra.clock.plist
defaults write com.apple.menuextra.clock IsAnalog -bool true

# Settings > Trackpad
# 	Point & Click Tab -> Check Tap to Click, Set Tracking speed to Fast
# 	More Gestures Tab -> Check App Expose
# Settings > General
# 	Appearance - Dark
# Settings > Accessibility > Mouse & Trackpad
# 	Trackpad Options… > Check enable dragging - 3 finger drag
# Settings > Accessibility > Zoom
# 	Check use scroll gesture with modifier keys (^ Ctrl) to zoom
# 	Zoom Style Options -> When zoomed in, choose [the screen moves continuously with pointer]
# Settings > Keyboard
# 	Tweak Key repeat & delay until repeat settings - make them faster
# 	Check turn keyboard backlight off after 5 secs of inactivity.
# 	Modifier Keys… > Caps Lock map to Escape
# 	Shortcuts > App Shortcuts > hit + > Safari.app, “Quit Safari”, Cmd-Opt-Q
# Settings > Bluetooth
# 	Check Show bluetooth in menu bar
# Settings > Software Update
# 	Check Automatically keep my Mac up to date.
# Battery Icon > Show percentage

# Notification Centre -> Scroll Up -> Turn on Night Shift
# iPhone Tethering override WiFi:
# 	Settings -> Network -> iPhone USB -> Uncheck disable unless needed.

killall Finder
killall Dock
killall SystemUIServer

