eval `dircolors $ZSH_CONFIG/LS_COLORS`

zmodload zsh/complist

# use LSCOLORS for tab completion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# case insensitive path-completion
autoload -Uz +X compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
