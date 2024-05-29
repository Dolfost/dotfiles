# Plugins (zplug)

zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
# zplug "zsh-users/zsh-completions"
zplug "themes/robbyrussell", from:oh-my-zsh, as:theme
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/web-search", from:oh-my-zsh
zplug "plugins/dirhistory", from:oh-my-zsh

zplug load
