# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Append to the history file, don't overwrite it.
# Essential for preserving commands across multiple concurrent terminal sessions.
shopt -s histappend

HISTSIZE=-1
HISTFILESIZE=-1
HISTCONTROL=ignoreboth

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS variable values globally.
# This prevents wrapping display bugs after resizing the terminal emulator.
shopt -s checkwinsize

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  # Use static paths instead of expensive `brew --prefix` subshell (~100ms savings).
  # Homebrew prefix is /opt/homebrew on Apple Silicon, /usr/local on Intel — never changes.
  elif [ -f /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
    . /opt/homebrew/etc/profile.d/bash_completion.sh
  elif [ -f /usr/local/etc/profile.d/bash_completion.sh ]; then
    . /usr/local/etc/profile.d/bash_completion.sh
  fi
fi

# The date.
export PS1="\n\[\e[0;31m\]\D{%r %A %Y-%m-%d}"
# The user & host name info.
PS1="$PS1 \[\e[0;37m\]| \[\e[0;35m\]\u@\h"
# Git repo branch (safe fallback).
if type -t __git_ps1 >/dev/null; then
    PS1="$PS1 \$(__git_ps1 '\[\e[0;37m\]| \[\e[0;33m\]git:(%s)')"
fi
# The work directory info.
PS1="$PS1\n\[\e[0;32m\]\w/"
# The actual bash prompt symbol.
PS1="$PS1\n\[\e[0;36m\]\$\[\e[0m\] "

# Added to give ssh access to my git repos seamlessly.
# Keychain manages the ssh-agent instance per-system rather than per-shell, 
# asking for passphrase only once upon reboot.
if command -v keychain &> /dev/null; then
    eval "$(keychain --eval github_ssh_key -q)"
fi

if [ -f ~/.bash_common ]; then
   source ~/.bash_common
fi
