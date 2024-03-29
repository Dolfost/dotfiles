export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=8000

setopt histverify
setopt append_history
setopt share_history
setopt hist_reduce_blanks
setopt prompt_cr
setopt transient_rprompt
setopt correct
setopt chase_links
setopt autocd
setopt braceccl
setopt extended_glob

unsetopt list_beep

zstyle ':completion:::::' completer _complete _approximate
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) )'
zstyle ':completion::*:(git add|less|rm|nvim):*' ignore-line true
zstyle ':completion:*' ignore-parents parent pwd
