# zsh aliases
if [ -n "$NVIM" ]; then
	PS1='$(basename `pwd`) » '
	if [ -x "$(command -v nvr)" ]; then
		alias nvim=nvr
	else
		alias nvim='echo "No neovim nesting!"'
	fi
fi

alias ll='ls -l'
alias la='ls -a'

alias c="clear"
alias p='pwd'
alias q='exit'
alias rf='rm -rf'

alias cwd='pwd | pbcopy'

alias grep='grep --color=auto'
alias ls='ls --color=auto'
