# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# Append to the history file, don't overwrite it
shopt -s histappend

HISTSIZE=-1
HISTFILESIZE=-1
HISTCONTROL=ignoreboth

# Check the window size after each command and, if necessary,
# Update the values of LINES and COLUMNS.
shopt -s checkwinsize


# The information on the current location.
if [ $(uname -m) == $(uname -p) ]; then
    unameinfo=$(uname -srm)
else
    unameinfo=$(uname -srmp)
fi

# The date.
export PS1="\n\[\e[0;31m\]\D{%r %A %Y-%m-%d}"
# The user & host name info.
PS1="$PS1 \[\e[0;37m\]| \[\e[0;35m\]\u@\h"
# Git repo branch.
PS1="$PS1 \$(__git_ps1 '\[\e[0;37m\]| \[\e[0;33m\]git:(%s)')"
# The work directory info.
PS1="$PS1\n\[\e[0;32m\]\w/"
# The actual bash.
PS1="$PS1\n\[\e[0;36m\]\$\[\e[0m\] "

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Added to give ssh access to my git repos.
# May need to install the keychain with
# sudo apt-get install keychain
eval $(keychain --eval github_ssh_key -q)

if [ -f ~/.bash_common ]; then
   source ~/.bash_common
fi
