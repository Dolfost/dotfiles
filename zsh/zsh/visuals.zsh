eval `dircolors $ZSH_CONFIG/dir_colors`

zmodload zsh/complist

zstyle ':completion:*:default' list-colors ${(s.:.)LSCOLORS}
