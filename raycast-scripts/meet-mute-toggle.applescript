#!/usr/bin/osascript

# Raycast Script Command Template
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Meet Mute Toggle
# @raycast.mode fullOutput
# @raycast.packageName Raycast Scripts
#
# Optional parameters:
# @raycast.icon 🎙
# @raycast.currentDirectoryPath ~
# @raycast.needsConfirmation false
#
# Documentation:
# @raycast.description Write a nice and descriptive summary about your script command here 
# @raycast.author Blesswin Samuel
# @raycast.authorURL An URL for one of your social medias


tell application "Arc"
    activate

    set _window_index to 1
    repeat with _window in windows
        set _tab_index to 1
        
        repeat with _tab in tabs of _window
            set _url to get URL of _tab
            if _url starts with "https://meet.google.com" then

                tell window _window_index
                    tell tab _tab_index to select
                end tell

                -- delay 0.5
                tell application "System Events" to tell process "Arc" to keystroke "d" using command down -- issue keyboard command
                return
            end if
            set _tab_index to _tab_index + 1
        end repeat
        
        set _window_index to _window_index + 1
    end repeat
end tell
