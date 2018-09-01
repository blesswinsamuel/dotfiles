#!/bin/sh

# Load Xresources
xrdb -merge ~/.Xresources

# Key mapping
xmodmap ~/.Xmodmap

exec i3
