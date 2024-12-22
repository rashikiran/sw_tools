#!/bin/bash


if [ "$1" = "" ];then
        echo "help : ./find.sh <search_dir>"
        exit 1
fi

DIR=`realpath $1`

if [ "$DIR" = "$PWD" ];then
        echo "search_dir can not be current directory"
        echo "help : ./find.sh <search_dir>"
        exit 1
fi

check_dir_and_exit()
{
        if [ ! -d "$1" ];then
                echo "dir \"$1\" not found. exiting ..."
                exit 1
        fi
}

check_file_and_exit()
{
        if [ ! -f "$1" ];then
                echo "file \"$1\" not found. exiting ..."
                exit 1
        fi
}

for i in $(find $DIR -iname "*.[ch]"); do
  sed -i '/^\s*return\s\+/!{ /^\s*\(static\s\+\)\?[a-zA-Z_][a-zA-Z0-9_]*\s\+[a-zA-Z_][a-zA-Z0-9_]*\s*(.*);/d }' "$i"
done

