# export invocations
export ZSH="$HOME/.oh-my-zsh"

export LANG=en_US.UTF-8

# cargo
if [[ "$OSTYPE" == "darwin"* ]]; then
	export PATH="$PATH:$HOME/.cargo/bin"
	# Add libgdiplus to csc library path on mac
	export DYLD_LIBRARY_PATH="/opt/homebrew/Cellar/mono-libgdiplus/6.1_2/lib/"
	export ZPLUG_HOME=/opt/homebrew/opt/zplug
else
	export ZPLUG_HOME=~/.zplug
fi

# My sctipts
export PATH="$PATH:$HOME/.scripts"

# Remove files in .gitignore from fzf list 
export FZF_DEFAULT_COMMAND='rg --files'

# zplug
source $ZPLUG_HOME/init.zsh
