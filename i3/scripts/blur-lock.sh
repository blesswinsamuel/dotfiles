#!/usr/bin/env bash

DIR="$( dirname "$0" )"

# Take screenshot
maim /tmp/screen.png

# Pixelate or Blur
mogrify -scale 10% -scale 1000% /tmp/screen.png # Pixelate
# convert /tmp/screen.png -filter Gaussian -blur 0x8 /tmp/screen.png # Blur

# Overlay lock image
if [[ -f $DIR/lock.svg ]]; then
  convert -density 1200 -background none -resize 186x186 $DIR/lock.svg /tmp/lock.png
  convert /tmp/screen.png /tmp/lock.png -gravity center -composite -matte /tmp/screen.png
fi

# Lock the screen
i3lock -i /tmp/screen.png

# Turn the screen off after a delay.
sleep 60; pgrep i3lock && xset dpms force off

