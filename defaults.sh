#!/bin/bash 
# MacOS defaults I like
# details: man defaults

defaults write com.apple.screencapture "disable-shadow" -bool "true"


# Defaults for yabai
defaults write com.apple.finder DisableAllAnimations -bool true
killall Finder # or logout and login
# to reset system defaults, delete the key instead
# defaults delete com.apple.finder DisableAllAnimations
