# zsh aliases
if [ -n "$NVIM" ]; then
	PS1='%2~ » '
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
alias h='history'

alias q='exit'
alias rf='rm -rf'

alias grep='grep --color=auto'
alias ls='ls --color=auto'

# If MacOS...
if [[ "$OSTYPE" == "darwin"* ]]; then
	alias cwd='pwd | pbcopy'
else
	alias cwd='pwd | xclip -i'
fi
