# zsh aliases
if [ -n "$NVIM" ]; then
	PS1='%2~ » '
	if [ -x "$(command -v nvr)" ]; then
		alias nvim=nvr
	else
		alias nvim='echo "No neovim nesting!"'
	fi
fi

alias grep='grep --color=auto'
alias ls='ls --color=auto'
