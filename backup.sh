#!/bin/bash

BACKUP_DIRECTORY="$HOME/Backup"
# BACKUP_DIRECTORY="/Volumes/BleSSD/Backups/Mac-Mini-2022-01-01"

mackup backup

cp -R ~/Downloads "$BACKUP_DIRECTORY/Downloads"
cp -R ~/.ssh "$BACKUP_DIRECTORY/.ssh"
mkdir -p $BACKUP_DIRECTORY/.kaggle
cp ~/.kaggle/kaggle.json "$BACKUP_DIRECTORY/.kaggle/kaggle.json"

mkdir -p $BACKUP_DIRECTORY/.config/rclone
cp ~/.config/rclone/rclone.conf "$BACKUP_DIRECTORY/.config/rclone/rclone.conf"

mkdir -p $BACKUP_DIRECTORY/.local/share/fish
cp ~/.local/share/fish/fish_history "$BACKUP_DIRECTORY/.local/share/fish/fish_history"
cp ~/.zsh_history "$BACKUP_DIRECTORY/.zsh_history"
cp ~/.zshenv "$BACKUP_DIRECTORY/.zshenv"

cp ~/.netrc "$BACKUP_DIRECTORY/.netrc"
cp ~/.profile "$BACKUP_DIRECTORY/.profile"

cp -R ~/vault "$BACKUP_DIRECTORY/vault"

# cp "$HOME/Library/Application Support/com.nuebling.mac-mouse-fix/config.plist" "$BACKUP_DIRECTORY/mac-mouse-fix-config.plist"

cp -R ~/dotfiles "$BACKUP_DIRECTORY/dotfiles"

cp -R ~/Mackup "$BACKUP_DIRECTORY/Mackup"

echo "iStat Menus"
echo "Session Buddy"
