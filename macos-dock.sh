#!/usr/bin/env bash -x

dockutil --remove all --no-restart

dockutil --add '/System/Applications/Launchpad.app' --label 'Launchpad' --no-restart
dockutil --add '/System/Applications/Mail.app' --label 'Mail' --no-restart
dockutil --add '/System/Applications/Messages.app' --label 'Messages' --no-restart
dockutil --add '/System/Applications/Contacts.app' --label 'Contacts' --no-restart
dockutil --add '/System/Applications/Calendar.app' --label 'Calendar' --no-restart
dockutil --add '/System/Applications/Reminders.app' --label 'Reminders' --no-restart
dockutil --add '/System/Applications/Notes.app' --label 'Notes' --no-restart
dockutil --add '/Applications/Notion.app' --label 'Notion' --no-restart
dockutil --add '/Applications/Telegram.app' --label 'Telegram' --no-restart
dockutil --add '/Applications/Slack.app' --label 'Slack' --no-restart
dockutil --add '/Applications/Trello.app' --label 'Trello' --no-restart
dockutil --add '' --type spacer --section apps --no-restart

dockutil --add '/Applications/Safari.app' --label 'Safari' --no-restart
dockutil --add '/Applications/Google Chrome.app' --label 'Google Chrome' --no-restart
dockutil --add '' --type spacer --section apps --no-restart

dockutil --add '/Applications/Sublime Text.app' --label 'Sublime Text' --no-restart
dockutil --add '/Applications/Sublime Merge.app' --label 'Sublime Merge' --no-restart
dockutil --add '/Applications/Visual Studio Code - Insiders.app' --label 'Visual Studio Code - Insiders' --no-restart
dockutil --add '' --type spacer --section apps --no-restart

dockutil --add '/System/Applications/App Store.app' --label 'App Store' --no-restart
dockutil --add '/System/Applications/Utilities/Activity Monitor.app' --label 'Activity Monitor' --no-restart
dockutil --add '/Applications/iTerm.app' --label 'iTerm' --no-restart
dockutil --add '/System/Applications/System Preferences.app' --label 'System Preferences' --no-restart

dockutil --add '/Applications' --view auto --display stack --sort dateadded --no-restart
dockutil --add '~/Downloads' --view auto --display stack --sort dateadded --no-restart
dockutil --add '~/Documents/Screenshots' --view auto --display stack --sort dateadded --no-restart

killall Dock
