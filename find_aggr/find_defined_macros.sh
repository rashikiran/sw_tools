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

#======================================================================================================================
create_ctags_file()
{
        echo "Creating tags file ..."
        ctags -R -f $DIR/tags $DIR
        check_file_and_exit $DIR/tags
}
create_ctags_file
#======================================================================================================================
create_all_defined_macros_list_fast_path()
{
	rm -f defined_macros_list.txt

	echo "Extract_macros ..."

	check_dir_and_exit $DIR

        grep -P '\s*\bd\b$' $DIR/tags | awk '{print $1}' > ./find_macros_temp.txt

	cat ./find_macros_temp.txt | sort | uniq > defined_macros_list.txt

	check_file_and_exit defined_macros_list.txt

	rm -f find_macros_temp.txt
}
create_all_defined_macros_list_fast_path
#======================================================================================================================
