bindkey -v
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

# tab suggestions vim navigation
# bindkey -M menuselect 'h' vi-backward-char
# bindkey -M menuselect 'k' vi-up-line-or-history
# bindkey -M menuselect 'l' vi-forward-char
# bindkey -M menuselect 'j' vi-down-line-or-history

bindkey ' ' magic-space
bindkey -M menuselect '\C-o' accept-and-menu-complete
