#The information on the current location.
export PS1="\h-\u:\w \$ "

#GREP with color views.
export GREP_OPTIONS="-n --color"

# Vi style prompt input
set -o vi

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

#Add colors to terminal
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
