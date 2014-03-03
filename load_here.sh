#!/bin/bash
#Loads all the appropriate files into this repo.
ls -A > temp_bash_dir
while read myline
do
    if [ "$myline" != "load_here.sh" ] && [ "$myline" != "temp_bash_dir" ] && [ "$myline" != ".git" ]
    then
    cp ~/$myline .
    fi
done < "temp_bash_dir"

rm -rf temp_bash_dir
