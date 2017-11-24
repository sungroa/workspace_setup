#Update ls to make it more convenient
computer_name=$(uname)
if [[ "$computer_name" == "Linux" ]]
then
    alias ls='ls --color=auto'
elif [[ "$computer_name" == "Darwin" ]]
then
    alias ls='ls -G'
fi
alias lsa='ls -A'
alias lsl='ls -hl'
alias lsla='ls -Ahl'
alias sl='ls'

#Make gnome-open for file opening more convenient for ubuntu
alias go='gnome-open'

#Alias for convenient cd commands.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'
alias cdh='cd /mnt/c/Users/Sung\ Roa\ Yoon/'

#Alias for viewing directory sizes.
alias d='du -d 1 -h'
