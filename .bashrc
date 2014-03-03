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
