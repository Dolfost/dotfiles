eval `dircolors $ZSH_CONFIG/LS_COLORS`

zmodload zsh/complist

# use LSCOLORS for tab completion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# case insensitive path-completion
autoload -Uz +X compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

# minimal theme setup
export MNML_PROMPT=(mnml_ssh mnml_pyenv mnml_status mnml_keymap)
export MNML_RPROMPT=('mnml_cwd 3 0' mnml_git)
export MNML_INFOLN=(mnml_err mnml_jobs mnml_uhp mnml_files)
export MNML_MAGICENTER=(mnml_me_dirs mnml_me_ls mnml_me_git)
