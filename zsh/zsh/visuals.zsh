eval `dircolors $ZSH_CONFIG/dir_colors`

zmodload zsh/complist

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-separator '-->'
zstyle ':completion*:default' menu 'select=0'

export MANPAGER='less --RAW-CONTROL-CHARS --use-color --color=d+g --color=u+y'
export MANROFFOPT="-c"

export RI_PAGER='less -R --use-color -Dd+r -Du+b'
export LESS='--mouse --wheel-lines 2 -RXF --use-color -Dd+r$Du+b'

export VISUAL='nvim'
