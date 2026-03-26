# Update ls to make it more convenient.
# This dynamically detects the OS to supply the appropriate colorized flags,
# since GNU ls uses '--color=auto' while BSD ls (macOS) uses '-G'.
computer_name=$(uname)
if [[ "$computer_name" == "Linux" ]]; then
    alias ls='ls --color=auto'

    # Alias for updates
    # Combine update, upgrade, and autoremove into one command for convenience
    alias saa='sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y'
elif [[ "$computer_name" == "Darwin" ]]; then
    alias saa='brew update && brew upgrade'
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
# Useful for jumping straight to the Windows user directory when operating inside WSL.
alias cdh='cd /mnt/c/Users/Sung\ Roa\ Yoon/'

# Alias for viewing directory sizes.
# Limits depth to 1 and uses human-readable sizes to quickly spot bloated folders.
alias d='du -d 1 -h'

# Alias for bazel.
# Routes to a specific project-local wrapper script dynamically.
alias bazel='$HOME/git/dataworks/setup/bin/bazel.sh'
