eval `dircolors $ZSH_CONFIG/dir_colors`

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

export VISUAL='nvim'
