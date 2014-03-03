#!/bin/bash
#Loads all the appropriate files into this repo.
ls -A > temp_bash_dir
rm -rf ~/.backup_my_personal_settings
mkdir ~/.backup_my_personal_settings
while read myline
do
    if [ "$myline" != "load_here.sh" ] && [ "$myline" != "temp_bash_dir" ] && [ "$myline" != ".git" ] && [ "$myline" != "copy_out.sh" ]
    then
        cp $myline ~/.backup_my_personal_settings
        cp ~/$myline .
    fi
done < "temp_bash_dir"

rm -rf temp_bash_dir
