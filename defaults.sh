#!/bin/bash 
# MacOS defaults I like
# details: man defaults

defaults write com.apple.screencapture "disable-shadow" -bool "true"
defaults write -g InitialKeyRepeat -float 12.0 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -float 1.0 # normal minimum is 2 (30 ms)

# Defaults for yabai
defaults write com.apple.finder DisableAllAnimations -bool true
killall Finder # or logout and login
# to reset system defaults, delete the key instead
# defaults delete com.apple.finder DisableAllAnimations
