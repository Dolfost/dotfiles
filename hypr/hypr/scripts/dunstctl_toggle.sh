#!/bin/sh

message() {
	notify-send -u normal -t 2000 -a dunst "" "$1"
}

if [ `dunstctl is-paused` = "false" ]; then 
	message "Disabling notifications"
	sleep 1
	dunstctl set-paused true
else
	message "Notifications enabled"
	dunstctl set-paused toggle
fi
