#!/bin/bash
#Loads all the appropriate files into this repo.
ls -A > temp_bash_dir
rm -rf ~/.backup_my_personal_settings
mkdir ~/.backup_my_personal_settings
while read myline
do
    if [[ ! "$myline" =~ ".swp" ]] && [[ ! "$myline" =~ ".sh" ]] && [ "$myline" != "temp_bash_dir" ] && [ "$myline" != "bash_history_cache" ] && [ "$myline" != ".git" ] && [ "$myline" != ".gitignore" ]
    then
        cp $myline ~/.backup_my_personal_settings
        cp ~/$myline .
    fi
done < "temp_bash_dir"

rm -rf temp_bash_dir
