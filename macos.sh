#!/usr/bin/env bash -x

# Change screenshot location
defaults write com.apple.screencapture location ~/Documents/Screenshots
# Alternative method: Cmd + Shift + 5 -> Options -> Save to Other location -> ~/Documents/Screenshots

# Settings > Trackpad
# 	Point & Click Tab -> Check Tap to Click, Set Tracking speed to Fast
# 	More Gestures Tab -> Check App Expose
# Settings > General
# 	Use dark menu bar and dock
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

# Dock spacer
# defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'

killall Finder
killall Dock
killall SystemUIServer

