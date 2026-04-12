# Managed by workspace_setup repository.
# Main configuration for the Zsh shell.

# If not running interactively, don't do anything
[[ $- == *i* ]] || return

setopt APPEND_HISTORY            # Write to the history file when the shell exits instead of overwriting.
setopt BANG_HIST                 # Treat the '!' character specially during expansion for history playback.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format for profiling.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, preserving entries even if the shell crashes.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt PROMPT_SUBST              # If set, the prompt string is first subjected to parameter expansion, command substitution and arithmetic expansion.
HISTSIZE=10000
HISTFILESIZE=1000000
SAVEHIST=$HISTFILESIZE

# Enable vi-mode keybindings for structural text editing on the prompt.
bindkey -v
# Map Ctrl-R explicitly to standard backward incremental search, overriding vi-mode default behavior.
bindkey '^R' history-incremental-search-backward

NEWLINE=$'\n'
# Enable native Zsh completion system with caching to minimize startup overhead.
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Minimal Async Git Prompt (Zero Bloat)
git_prompt_cache="/tmp/.zsh_git_prompt_$$"

_update_git_prompt() {
    (
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [[ -n "$branch" ]]; then
            echo "| %F{yellow}git:($branch)%f" > "$git_prompt_cache"
        else
            echo "" > "$git_prompt_cache"
        fi
        kill -s USR1 $$
    ) &!
}

TRAPUSR1() {
    ASYNC_GIT_INFO="$(cat "$git_prompt_cache" 2>/dev/null)"
    zle && zle reset-prompt
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _update_git_prompt
ASYNC_GIT_INFO=""

PS1='${NEWLINE}%F{red}%D{%L:%M:%S %p %A %Y-%m-%d}%f | %F{5}%n@%m%f ${ASYNC_GIT_INFO}${NEWLINE}%F{green}%~%f${NEWLINE}$ '

# Added to give ssh access to my git repos seamlessly.
# Keychain manages the ssh-agent instance per-system rather than per-shell,
# asking for passphrase only once upon reboot.
if command -v keychain &> /dev/null; then
    eval "$(keychain --eval github_ssh_key -q)"
fi

if [ -f ~/.bash_common ]; then
   source ~/.bash_common
fi
