export ZSH="$HOME/.oh-my-zsh"

if [[ "$(uname -s)" == "Darwin"* ]]; then
	export PATH="$PATH:$HOME/.cargo/bin"
	export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
	PATH="/opt/homebrew/opt/gnu-tar/libexec/gnubin:$PATH"
	PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
	PATH="/opt/homebrew/opt/gnu-which/libexec/gnubin:$PATH"
fi

export PATH="$PATH:$HOME/.local/bin"

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=8000
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

export VISUAL='nvim'
export EDITOR='nvim'
export PAGER='less'

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
