setopt APPEND_HISTORY            # Write to the history file when the shell exits.
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
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

bindkey -v
bindkey '^R' history-incremental-search-backward

NEWLINE=$'\n'
git_prompt_component() {
  local BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ -n "${BRANCH}" ]]; then
    echo "| %F{yellow}git:(${BRANCH})%f"
  fi
}
PS1='${NEWLINE}%F{red}%D{%L:%M:%S %p %A %Y-%m-%d}%f | %F{5}%n@%m%f $(git_prompt_component)${NEWLINE}%F{green}%~%f${NEWLINE}$ '

if [ -f ~/.bash_common ]; then
   source ~/.bash_common
fi
