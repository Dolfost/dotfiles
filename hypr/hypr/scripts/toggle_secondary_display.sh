#!/bin/bash

SECONDARY_MONITOR="HDMI-A-1"
SECONDARY_MONITOR_MODELINE="3840x2160@60, 2560x0, 1.333334"
hyprctl monitors | grep $SECONDARY_MONITOR 
IS_ENABLED=$?
NID=7493270
if [  $IS_ENABLED = "0" ]; then 
	hyprctl keyword monitor $SECONDARY_MONITOR , disable
	status=$?
	if [ "$status" = "0" ]; then
		notify-send -r $NID -u low -a hyprctl "󰹑  󰨙 " "External monitor OFF"
	fi
else
	hyprctl keyword monitor $SECONDARY_MONITOR , $SECONDARY_MONITOR_MODELINE
	status=$?
	if [ "$status" = "0" ]; then
		notify-send -r $NID -u low -a hyprctl "󰹑  󰨚 " "External monitor ON"
	fi
fi
