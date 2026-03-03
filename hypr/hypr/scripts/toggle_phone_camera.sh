#!/bin/bash

message() {
	notify-send -r 40238434 -u low -a scrcpy "Phone Camera" "$1"
}

if systemctl --user is-active --quiet phone-camera.service; then
    systemctl --user stop phone-camera.service
		message "Stopped"
else
    systemctl --user start phone-camera.service
    message "Started"
fi
