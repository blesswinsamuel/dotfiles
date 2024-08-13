#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Microphone
# @raycast.mode silent
# @raycast.packageName System

# Optional parameters:
# @raycast.icon 🎙

# Documentation:
# @raycast.author Blesswin Samuel
# @raycast.authorURL blesswinsamuel.com

on getMicrophoneVolume()
	input volume of (get volume settings)
end getMicrophoneVolume

on disableMicrophone()
	set volume input volume 0
  log "Muted 🔴"
end disableMicrophone

on enableMicrophone()
	set volume input volume 100
  log "Unmuted 🟢"
end enableMicrophone

if getMicrophoneVolume() < 5 then
	enableMicrophone()
else
	disableMicrophone()
end if
