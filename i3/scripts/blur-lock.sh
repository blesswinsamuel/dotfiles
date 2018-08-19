#!/bin/bash
DIR="$( dirname "$0" )"

maim /tmp/screen.png
convert /tmp/screen.png -scale 10% -scale 1000% /tmp/screen.png # Pixelate
# convert /tmp/screen.png -filter Gaussian -blur 0x8 /tmp/screen.png # Blur
[[ -f $DIR/lock.svg ]] && \
  convert -density 1200 -background none -resize 186x186 $DIR/lock.svg /tmp/lock.png && \
  convert /tmp/screen.png /tmp/lock.png -gravity center -composite -matte /tmp/screen.png
i3lock -i /tmp/screen.png
