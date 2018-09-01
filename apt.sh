#!/usr/bin/env bash

sudo -v

sudo apt install apt-transport-https

sudo add-apt-repository -y ppa:papirus/papirus

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
wget -qO - http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc | sudo apt-key add -
echo 'deb http://download.virtualbox.org/virtualbox/debian bionic contrib' | sudo tee /etc/apt/sources.list.d/virtualbox.org.list

sudo apt update

sudo apt install -y \
  openssh-server openssh-client autossh net-tools x11vnc \
  fish vim git curl tmux htop \
  imagemagick fontforge \
  i3 i3blocks \
  rofi dunst maim compton \
  feh \
  ranger tig \
  sublime-text virtualbox-5.2 \
  lxappearance xbacklight xclip thunar google-chrome-stable \
  arc-theme papirus-icon-theme \
;

# VirtualBox extension pack
LATEST_VBOX_VERSION=$(wget -qO - http://download.virtualbox.org/virtualbox/LATEST.TXT)
wget -O "/tmp/Oracle_VM_VirtualBox_Extension_Pack-${LATEST_VBOX_VERSION}.vbox-extpack" "http://download.virtualbox.org/virtualbox/${LATEST_VBOX_VERSION}/Oracle_VM_VirtualBox_Extension_Pack-${LATEST_VBOX_VERSION}.vbox-extpack"
sudo VBoxManage extpack install --accept-license=56be48f923303c8cababb0bb4c478284b688ed23f16d775d729b89a2e8e5f9eb --replace "/tmp/Oracle_VM_VirtualBox_Extension_Pack-${LATEST_VBOX_VERSION}.vbox-extpack"
rm "/tmp/Oracle_VM_VirtualBox_Extension_Pack-${LATEST_VBOX_VERSION}.vbox-extpack"

# greenclip
sudo wget -O /usr/local/bin/greenclip https://github.com/erebe/greenclip/releases/download/3.0/greenclip && sudo chmod +x /usr/local/bin/greenclip

chsh -s `which fish`

sudo update-alternatives --set x-window-manager /usr/bin/i3
# sudo update-alternatives --set x-terminal-emulator

# fontawesome 5.2.0
curl --create-dirs -Lo /tmp/fontawesome.zip https://github.com/FortAwesome/Font-Awesome/releases/download/5.2.0/fontawesome-free-5.2.0-desktop.zip \
  && unzip /tmp/fontawesome.zip -d /tmp \
  && rm -f /tmp/fontawesome.zip \
  && find /tmp/fontawesome-free-5.2.0-desktop/otfs -iname '*.otf' -exec fontforge -lang=ff -c 'Print("Opening " + $1); Open($1); Print("Saving " + $1:r + ".ttf"); Generate($1:r + ".ttf"); Quit(0);' {} \; \
  && mkdir -p ~/.fonts \
  && mv /tmp/fontawesome-free-5.2.0-desktop/otfs/*.ttf ~/.fonts \
  && rm -rf /tmp/fontawesome-free-5.2.0-desktop

# sudo fc-cache -f -v
