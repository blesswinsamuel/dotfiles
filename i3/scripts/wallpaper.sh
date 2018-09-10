#!/usr/bin/env bash

mkdir -p ~/Pictures && curl -Lo ~/Pictures/wallpaper.jpg "http://source.unsplash.com/1920x1200"
feh --bg-scale $HOME/Pictures/wallpaper.jpg
