eval `dircolors $ZSH_CONFIG/dir_colors`

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

export MANPAGER='less --RAW-CONTROL-CHARS --use-color --color=d+g --color=u+y'
export MANROFFOPT="-c"

export RI_PAGER='less -R --use-color -Dd+r -Du+b'
export LESS='-RXF --use-color -Dd+r$Du+b'

export VISUAL='nvim'
