#!/bin/bash

ORIENTATION=$1

SECONDARY_MONITOR="HDMI-A-1"
if [ "$ORIENTATION" == "horizontal" ]; then
	MONITOR_ARGS="mode='3840x2160@60', position='2560x0', scale=1.333334, disabled=false"
elif [ "$ORIENTATION" == "vertical" ]; then
	MONITOR_ARGS="mode='3840x2160@60', position='2560x-900', scale=1.333334, transform=3, disabled=false"
elif [ "$ORIENTATION" == "mirror" ]; then
	MONITOR_ARGS="mode='preferred', position='auto', scale=1, mirror='DP-1', disabled=false"
fi

hyprctl monitors | grep $SECONDARY_MONITOR 
IS_ENABLED=$?

NID=7493270
if [  $IS_ENABLED = "0" ]; then 
	hyprctl eval "hl.monitor({output='$SECONDARY_MONITOR', disabled=true})"
	status=$?
	if [ "$status" = "0" ]; then
		notify-send -r $NID -u low -a hyprctl "󰹑  󰨙 " "External monitor OFF"
	fi
else
	hyprctl eval "hl.monitor({output='$SECONDARY_MONITOR', $MONITOR_ARGS})"
	status=$?
	if [ "$status" = "0" ]; then
		notify-send -r $NID -u low -a hyprctl "󰹑  󰨚 " "External monitor ON"
	fi
fi
