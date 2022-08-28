#!/usr/bin/env bash -x

dockutil --remove all --no-restart

dockutil --add '/System/Applications/Launchpad.app' --label 'Launchpad' --no-restart
dockutil --add '/Applications/ForkLift.app' --label 'ForkLift' --no-restart
dockutil --add '/System/Applications/Mail.app' --label 'Mail' --no-restart
dockutil --add '/System/Applications/Messages.app' --label 'Messages' --no-restart
dockutil --add '/System/Applications/Contacts.app' --label 'Contacts' --no-restart
dockutil --add '/System/Applications/Calendar.app' --label 'Calendar' --no-restart
dockutil --add '/System/Applications/Reminders.app' --label 'Reminders' --no-restart
dockutil --add '/System/Applications/Notes.app' --label 'Notes' --no-restart
dockutil --add '/System/Applications/Podcasts.app' --label 'Podcasts' --no-restart
dockutil --add '/System/Applications/Music.app' --label 'Music' --no-restart
dockutil --add '/System/Applications/VoiceMemos.app' --label 'Voice Memos' --no-restart

dockutil --add '' --type spacer --section apps --no-restart
dockutil --add '/Applications/Telegram.app' --label 'Telegram' --no-restart
dockutil --add '/Applications/Slack.app' --label 'Slack' --no-restart
dockutil --add '/Applications/Home Assistant.app' --label 'Home Assistant' --no-restart
dockutil --add '/System/Applications/Home.app' --label 'Home' --no-restart

dockutil --add '' --type spacer --section apps --no-restart
dockutil --add '/Applications/Microsoft Teams.app' --label 'Microsoft Teams' --no-restart
dockutil --add '/Applications/Microsoft Outlook.app' --label 'Microsoft Outlook' --no-restart
dockutil --add '/Applications/Numbers.app' --label 'Numbers' --no-restart

dockutil --add '' --type spacer --section apps --no-restart
dockutil --add '/Applications/Safari.app' --label 'Safari' --no-restart
dockutil --add '/Applications/Google Chrome.app' --label 'Google Chrome' --no-restart
dockutil --add '/Applications/Firefox.app' --label 'Firefox' --no-restart
dockutil --add '/Applications/IINA.app' --label 'IINA' --no-restart

dockutil --add '' --type spacer --section apps --no-restart
dockutil --add '/Applications/Visual Studio Code.app' --label 'Visual Studio Code' --no-restart
dockutil --add '/Applications/Sublime Text.app' --label 'Sublime Text' --no-restart
dockutil --add '/Applications/Sublime Merge.app' --label 'Sublime Merge' --no-restart
dockutil --add '/Applications/GitHub Desktop.app' --label 'GitHub Desktop' --no-restart
dockutil --add '/Applications/Postico.app' --label 'Postico' --no-restart
dockutil --add '/Applications/TablePlus.app' --label 'TablePlus' --no-restart
dockutil --add '/Applications/iTerm.app' --label 'iTerm' --no-restart
dockutil --add '/Applications/IntelliJ IDEA.app' --label 'IntelliJ IDEA' --no-restart
dockutil --add '/Applications/Podman Desktop.app' --label 'Podman Desktop' --no-restart

dockutil --add '' --type spacer --section apps --no-restart
dockutil --add '/System/Applications/Utilities/Activity Monitor.app' --label 'Activity Monitor' --no-restart
dockutil --add '/System/Applications/Utilities/Console.app' --label 'Console' --no-restart
dockutil --add '/System/Applications/App Store.app' --label 'App Store' --no-restart
dockutil --add '/System/Applications/System Preferences.app' --label 'System Preferences' --no-restart

dockutil --add '' --type spacer --section apps --no-restart
dockutil --add '/Applications/MainStage 3.app' --label 'MainStage' --no-restart
dockutil --add '/Applications/Logic Pro X.app' --label 'Logic Pro' --no-restart
dockutil --add '/Applications/Final Cut Pro.app' --label 'Final Cut Pro' --no-restart


dockutil --add '/Applications' --view auto --display stack --sort dateadded --no-restart
dockutil --add '~/Downloads' --view auto --display stack --sort dateadded --no-restart
dockutil --add '/Volumes/BleSSD/Screenshots' --view auto --display stack --sort dateadded --no-restart

killall Dock
