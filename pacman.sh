#!/usr/bin/env bash

USERNAME=${USERNAME:-bless}

sudo pacman -S --needed --noconfirm \
  git tmux htop wget tree vim reptyr imagemagick networkmanager fish x11vnc ffmpeg maim \
  xorg-server xorg-xinit xorg-xprop xorg-xbacklight xorg-xinput xsel xclip xautolock i3-gaps i3blocks i3lock rofi compton feh dunst dmenu \
  pulseaudio alsa-utils pulseaudio-alsa \
  network-manager-applet \
  rxvt-unicode pcmanfm lxappearance simplescreenrecorder flameshot \
  nodejs python \
  chromium firefox \
  arc-gtk-theme papirus-icon-theme \
  ttf-dejavu ttf-liberation ttf-inconsolata ttf-fira-code adobe-source-sans-pro-fonts otf-font-awesome \
;

chsh -s /usr/bin/fish ${USERNAME}
fish_update_completions

git clone https://aur.archlinux.org/yay.git /tmp/yay && (cd /tmp/yay ; makepkg -si --noconfirm) && rm -rf /tmp/yay
yay -S --needed --noconfirm rofi-greenclip dunstify \
    sublime-text-dev visual-studio-code-bin \
	urxvt-resize-font-git urxvt-tabbedex
sudo ln -sf /usr/bin/subl3 /usr/bin/subl

# Enable services
systemctl enable NetworkManager.service
