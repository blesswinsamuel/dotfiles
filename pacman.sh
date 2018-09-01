#!/usr/bin/env bash

USERNAME=${USERNAME:-arch}

sudo pacman -S --needed --noconfirm base-devel

sudo pacman -S --needed --noconfirm \
  git tmux htop wget tree vim reptyr imagemagick openssh networkmanager fish x11vnc ffmpeg maim \
  xorg-server xorg-xinit xorg-xprop xsel xclip i3-gaps i3blocks i3lock rofi compton feh dunst dmenu \
  rxvt-unicode pcmanfm lxappearance simplescreenrecorder flameshot \
  nodejs python \
  chromium firefox \
  arc-gtk-theme papirus-icon-theme \
  ttf-dejavu ttf-liberation ttf-inconsolata ttf-fira-code adobe-source-sans-pro-fonts otf-font-awesome \
;

chsh -s /usr/bin/fish ${USERNAME}
fish_update_completions

git clone https://aur.archlinux.org/yay.git /tmp/yay && (cd /tmp/yay ; makepkg -si --noconfirm) && rm -rf /tmp/yay
yay -S --needed --noconfirm rofi-greenclip sublime-text-dev visual-studio-code-bin
sudo ln -sf /usr/bin/subl3 /usr/bin/subl

# Enable services
systemctl enable sshd.socket
systemctl enable NetworkManager.service
