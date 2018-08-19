#!/usr/bin/env bash

sudo apt install apt-transport-https

sudo add-apt-repository -y ppa:snwh/ppa

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
wget -qO - http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc | sudo apt-key add -
echo 'deb http://download.virtualbox.org/virtualbox/debian bionic contrib' | sudo tee /etc/apt/sources.list.d/virtualbox.org.list

sudo apt update

sudo apt install -y \
  openssh-server openssh-client net-tools x11vnc \
  fish vim git curl tmux \
  imagemagick \
  i3 i3blocks \
  rofi dunst maim compton \
  feh \
  ranger tig \
  sublime-text virtualbox-5.2 \
  fonts-font-awesome \
  lxappearance xbacklight thunar google-chrome-stable \
  arc-theme paper-icon-theme  \
;

# greenclip
sudo wget -O /usr/local/bin/greenclip https://github.com/erebe/greenclip/releases/download/3.0/greenclip && sudo chmod +x /usr/local/bin/greenclip

chsh -s `which fish`

# Set wallpaper
wget -O ~/Pictures/wallpaper.jpg http://www.wallpapers13.com/wp-content/uploads/2016/03/Evening-on-the-blue-Lake-Tekapo-desktop-wallpaper-hd-widescreen-free-download.jpg

sudo update-alternatives --set x-window-manager /usr/bin/i3
# sudo update-alternatives --set x-terminal-emulator 

# x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :0 -usepw
