#!/bin/bash

# You can call this script like this:
# $./brightness.sh up
# $./brightness.sh down
# $./brightness.sh mute

function get_brightness {
    xbacklight -get
}

function send_notification {
    brightness=`get_brightness`
    # Make the bar with the special character ─ (it's not dash -)
    # https://en.wikipedia.org/wiki/Box-drawing_character
    bar=$(seq -s "─" $((${brightness%.*} / 5)) | sed 's/[0-9]//g')
    # Send the notification
    dunstify -t 2500 -r 2593 -u normal "    $bar"
}

case $1 in
    up)
	xbacklight -inc 10
	send_notification
	;;
    down)
	xbacklight -dec 10
	send_notification
	;;
esac
