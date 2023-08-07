# export invocations
export ZSH="$HOME/.oh-my-zsh"

# cargo
if [[ "$OSTYPE" == "darwin"* ]]; then
	export PATH=$PATH:/Users/vladyslav/.cargo/bin
fi

# My sctipts
export PATH=$PATH:$HOME/.scripts

# Add libgdiplus to csc library path on mac
if [[ "$OSTYPE" == "darwin"* ]]; then
	export DYLD_LIBRARY_PATH="/opt/homebrew/Cellar/mono-libgdiplus/6.1_2/lib/"
fi

# Remove files in .gitignore from fzf list 
export FZF_DEFAULT_COMMAND='rg --files'

# zplug
if [[ "$OSTYPE" == "darwin"* ]]; then
	export ZPLUG_HOME=/opt/homebrew/opt/zplug
else
	export ZPLUG_HOME=/usr/share/zplug
fi
source $ZPLUG_HOME/init.zsh


# User configuration
export TERM=xterm-256color
