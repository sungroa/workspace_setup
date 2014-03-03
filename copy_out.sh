#!/bin/bash
#Copies out all the appropriate files from this repo to ~.
ls -A > temp_bash_dir
while read myline
do
    if [ "$myline" != "load_here.sh" ] && [ "$myline" != "temp_bash_dir" ] && [ "$myline" != ".git" ]
    then
    cp $myline ~ 
    fi
done < "temp_bash_dir"

rm -rf temp_bash_dir
