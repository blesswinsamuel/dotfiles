#!/usr/bin/env bash

### Documentation
# ~/.macos — https://mths.be/macos
# https://macos-defaults.com

### Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

### Show full URL in Safari
# https://macos-defaults.com/safari/showfullurlinsmartsearchfield.html
# defaults read com.apple.safari
defaults write com.apple.safari ShowFullURLInSmartSearchField -bool true

### Set minimize effect to scale
# https://macos-defaults.com/dock/mineffect.html#requirements
# defaults read com.apple.dock
defaults write com.apple.dock mineffect -string "scale"

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

# Itsycal
defaults write com.mowglii.ItsycalApp ClockFormat -string "h:mm:ss a"
defaults write com.mowglii.ItsycalApp HighlightedDOWs -int 65  # Sunday and Saturday
defaults write com.mowglii.ItsycalApp MoCalendarNumRows -int 6
defaults write com.mowglii.ItsycalApp ShowEventDays -int 7  # Event list shows: 7 days
defaults write com.mowglii.ItsycalApp ShowMonthInIcon -int 1  # Show month in icon
defaults write com.mowglii.ItsycalApp ShowWeeks -int 1  # Show calendar weeks
defaults write com.mowglii.ItsycalApp SizePreference -int 1  # Font size
defaults write com.mowglii.ItsycalApp UseOutlineIcon -int 1  # Show outline icon
defaults write com.mowglii.ItsycalApp ShowDayOfWeekInIcon -int 1  # Show day of week in icon

### iTerm2
## Specify the preferences directory
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/dotfiles/configs/iterm2"
## Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
