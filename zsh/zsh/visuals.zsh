eval `dircolors $ZSH_CONFIG/dir_colors`

zmodload zsh/complist

# use LSCOLORS for tab completion
zstyle ':completion:*:default' list-colors ${(s.:.)LSCOLORS}

# case insensitive path-completion
autoload -Uz +X compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
