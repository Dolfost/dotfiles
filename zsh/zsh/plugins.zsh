# Plugins (zplug)

zplug "plugins/git", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#616161, bg=None, bold, underline"
zplug "themes/robbyrussell", from:oh-my-zsh, as:theme

zplug load
zplug list
