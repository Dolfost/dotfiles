#!/usr/bin/env bash 

hyprctl dispatch resizeactive exact $(walker --dmenu --inputonly --placeholder "Resize window: width height or width% height%")
