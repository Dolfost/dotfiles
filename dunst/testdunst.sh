#!/bin/env sh

notify-send -h string:fgcolor:#ff4444 "Message 1"
notify-send -h string:bgcolor:#4444ff -h string:fgcolor:#ff4444 -h string:frcolor:#44ff44 "Message 2"
notify-send -h int:value:42 "Working ..."
notify-send -i info "Information" "This is an informational message."
