computer_name=$(uname)
if [[ "$computer_name" != "Darwin" ]]
then
    alias ls='ls --color=auto'
fi
alias lsa='ls -A'
alias lsl='ls -hl'
alias lsla='ls -Ahl'
alias sl='ls'

alias go='gnome-open'
alias research='ssh sungroa@s141.millennium.berkeley.edu'

alias ..='cd ..'
alias ...='cd ...'
alias ....='cd ....'
alias cd..='cd ..'

alias d='du -d 1 -h'
