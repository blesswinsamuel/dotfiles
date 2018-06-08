#!/usr/bin/env bash
local dir=$PWD
local backup_dir=~/dotfiles_old

mkdir $backup_dir

mv ~/.config/fish ~/dotfiles_old/
ln -s ./fish/config.fish ~/.config/fish/config.fish
ln -s ./fish/functions ~/.config/fish/functions

mv ~/.config/tmux.conf $backup_dir
ln -s ./tmux.conf ~/.tmux.conf

echo '# The mere presence of this file in the home directory disables the system
# copyright notice, the date and time of the last login, the message of the
# day as well as other information that may otherwise appear on login.
# See `man login`.' > ~/.hushlogin


