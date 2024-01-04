#!/bin/bash

bundleid() {
  osascript -e "id of app \"$*\""
}

# swda getUTIs

# https://superuser.com/questions/273756/how-to-change-default-app-for-all-files-of-particular-file-type-through-terminal
# duti -s $(bundleid 'Visual Studio Code') .md all

# https://superuser.com/a/1720935/136654
# swda setHandler --app "/Applications/Visual Studio Code.app" --UTI org.yaml.yaml
swda setHandler --app "/Applications/Visual Studio Code.app" --UTI public.md
swda setHandler --app "/Applications/Visual Studio Code.app" --UTI public.yaml
swda setHandler --app "/Applications/Visual Studio Code.app" --UTI org.go.source

# echo 'com.apple.TextEdit   com.microsoft.word.doc all' | duti
