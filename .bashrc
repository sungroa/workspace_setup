#The information on the current location.
if [ $(uname -m) == $(uname -p) ]; then
    unameinfo=$(uname -srm)
else
    unameinfo=$(uname -srmp)
fi

export PS1="\n\[\e[0;36m\][\]\[\e[0;31m\]\D{%r %A %D}\] \[\e[0;35m\]\u@\h\] \[\e[0;33m\]$unameinfo\]\[\e[0;36m\]]\]"
PS1="$PS1\n\[\e[0;36m\][\]\[\e[0;32m\]\w\[\e[0;36m\]]\]"
PS1="$PS1\n\[\e[0;36m\]\$\]\[\e[0m\] "

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

#Add colors to terminal for Mac, for files in ls.
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
