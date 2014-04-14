#Update ls to make it more convenient
computer_name=$(uname)
if [[ "$computer_name" != "Darwin" ]]
then
    alias ls='ls --color=auto'
fi
alias lsa='ls -A'
alias lsl='ls -hl'
alias lsla='ls -Ahl'
alias sl='ls'

#Make gnome-open for file opening more convenient for ubuntu
alias go='gnome-open'

#Make alias for convenient ssh
alias research='ssh sungroa@s141.millennium.berkeley.edu'

#Alias for convenient cd commands.
alias ..='cd ..'
alias ...='cd ...'
alias ....='cd ....'
alias cd..='cd ..'

#Alias for viewing directory sizes.
alias d='du -d 1 -h'
