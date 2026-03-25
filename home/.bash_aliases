# Update ls to make it more convenient
computer_name=$(uname)
if [[ "$computer_name" == "Linux" ]]
then
    alias ls='ls --color=auto'

    # Alias for updates
    alias saa='sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y'
elif [[ "$computer_name" == "Darwin" ]]
    alias saa='brew update && brew upgrade'
then
    alias ls='ls -G'
fi
alias lsa='ls -A'
alias lsl='ls -hl'
alias lsla='ls -Ahl'
alias sl='ls'

# Alias for convenient cd commands.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cd..='cd ..'
# Alias specifically for the Windows Terminal.
alias cdh='cd /mnt/c/Users/Sung\ Roa\ Yoon/'

# Alias for viewing directory sizes.
alias d='du -d 1 -h'

# Alias for bazel.
alias bazel='$HOME/git/dataworks/setup/bin/bazel.sh'
