sudo apt-add-repository ppa:fish-shell/release-2
sudo add-apt-repository ppa:snwh/ppa
sudo add-apt-repository ppa:jasonpleau/rofi

sudo apt update

sudo apt install \
  fish \
  fontforge \
  lxappearance \
  feh \
  rofi \
  compton \
  i3blocks \
  thunar \
  ranger
  paper-icon-theme \
  arc-theme

# greenclip
sudo wget -O /usr/local/bin/greenclip https://github.com/erebe/greenclip/releases/download/3.0/greenclip && sudo chmod +x /usr/local/bin/greenclip

# Dunst
sudo apt install \
  libdbus-1-dev libx11-dev libxinerama-dev \
  libxrandr-dev libxss-dev libglib2.0-dev \
  libpango1.0-dev libgtk-3-dev libxdg-basedir-dev \
  checkinstall && git clone https://github.com/dunst-project/dunst.git /tmp/dunst && (cd /tmp/dunst && make && sudo make install) && rm -rf /tmp/dunst

# Fonts
curl --create-dirs -Lo /tmp/fontawesome.zip https://github.com/FortAwesome/Font-Awesome/releases/download/5.2.0/fontawesome-free-5.2.0-desktop.zip \
  && unzip /tmp/fontawesome.zip -d /tmp \
  && rm -f /tmp/fontawesome.zip \
  && find /tmp/fontawesome-free-5.2.0-desktop/otfs -iname '*.otf' -exec fontforge -lang=ff -c 'Print("Opening " + $1); Open($1); Print("Saving " + $1:r + ".ttf"); Generate($1:r + ".ttf"); Quit(0);' {} \; \
  && mkdir -p ~/.fonts \
  && mv /tmp/fontawesome-free-5.2.0-desktop/otfs/*.ttf ~/.fonts \
  && rm -rf /tmp/fontawesome-free-5.2.0-desktop
curl --create-dirs -Lo /tmp/SanFranciscoFont-master.zip https://github.com/AppleDesignResources/SanFranciscoFont/archive/master.zip \
  && unzip /tmp/SanFranciscoFont-master.zip -d /tmp \
  && rm -f /tmp/SanFranciscoFont-master.zip \
  && find /tmp/SanFranciscoFont-master -iname '*.otf' -exec fontforge -lang=ff -c 'Print("Opening " + $1); Open($1); Print("Saving " + $1:r + ".ttf"); Generate($1:r + ".ttf"); Quit(0);' {} \; \
  && mkdir -p ~/.fonts \
  && mv /tmp/SanFranciscoFont-master/*.ttf ~/.fonts \
  && rm -rf /tmp/SanFranciscoFont-master
sudo fc-cache -f -v

# Change shell
cat /etc/shells
chsh -s `which fish`

# Change i3 terminal
man i3-sensible-terminal
sudo update-alternatives --config x-terminal-emulator
