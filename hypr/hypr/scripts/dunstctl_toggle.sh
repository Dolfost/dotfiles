#!/bin/sh

message() {
	notify-send -u low -a dunst "Notifications" "$1"
}

if [ `dunstctl is-paused` = "false" ]; then 
	message "󰖁 Disabled"
	sleep 1
	dunstctl set-paused true
else
	message "󰕾 Enabled"
	dunstctl set-paused toggle
fi
