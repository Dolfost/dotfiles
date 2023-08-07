# export invocations

export PATH=$PATH:/Users/vladyslav/.cargo/bin
export ZSH="$HOME/.oh-my-zsh"

# lvim
export PATH=$PATH:/Users/vladyslav/.local/bin

# My sctipts
export PATH=$PATH:$HOME/.scripts

# Add libgdiplus to csc library path on mac
export DYLD_LIBRARY_PATH="/opt/homebrew/Cellar/mono-libgdiplus/6.1_2/lib/"

# Remove files in .gitignore from fzf list 
export FZF_DEFAULT_COMMAND='rg --files'

# zplug
export ZPLUG_HOME=/opt/homebrew/opt/zplug
source $ZPLUG_HOME/init.zsh

# User configuration
export TERM=xterm-256color

# What?
export PATH="$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin"
