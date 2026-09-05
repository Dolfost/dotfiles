#!/bin/sh
hyprctl hyprsunset temperature "$(printf '%s\n' 6000 2500 3000 3500 4000 4500 5000 5500 | walker --dmenu --placeholder 'Temperature °K')"
