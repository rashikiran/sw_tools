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
remove_old_results()
{
	echo "Removing old results ..."
	rm -f ./fun_def_list.txt
}
remove_old_results
#======================================================================================================================
create_ctags_file()
{
	echo "Creating tags file ..."
	ctags -R -f $DIR/tags $DIR
	check_file_and_exit $DIR/tags
}
create_ctags_file
#======================================================================================================================
#create_fun_def_list_slow_path
create_fun_def_list_fast_path()
{
	echo "Creating v1.0 of fun_def_list.txt : fast path ..."

	rm -f find_def_list.txt

	check_dir_and_exit $DIR
	check_file_and_exit $DIR/tags

	grep -P '\s*\bf\b$' $DIR/tags | awk '{print $1}' > ./fun_def_list.txt

	grep -P '\s*\bf\b\s+\bfile:$' $DIR/tags | awk '{print $1}' >> ./fun_def_list.txt
}
create_fun_def_list_fast_path
#======================================================================================================================
