#!/usr/bin/env bash 

hyprctl dispatch resizeactive exact $(fuzzel --dmenu --prompt 'Resize window: ' --lines 0 --placeholder "width height or width% heigth%")
