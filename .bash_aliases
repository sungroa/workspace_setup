computer_name=$(uname)
if [[ "$computer_name" != "Darwin" ]]
then
    alias ls='ls --color=auto'
fi
alias lsa='ls -A'
