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
create_make_defined_macros_list_fast_path()
{
	rm -f defined_macros_list.txt

	echo "Extract_make_defined_macros ..."

	check_dir_and_exit $DIR

	for i in `find $DIR -type f -iname "*makefile*" -print`
	do
		echo "Makefile is $i,Header" > ./find_macros_temp.txt
		grep -n "\-D" $i  |  sed 's/^[ \t]*//'  |  grep -oP '\s*-D\w+' | sed 's/^[ \t]*//'   | sort  | uniq > temp_f.txt
		cat temp_f.txt >> ./find_macros_temp.txt
	done

	for i in `find $DIR -type f -iname "*cmake*" -print`
	do
		echo "Cmakefile is $i,Header" >> ./find_macros_temp.txt
		grep -n "\-D" $i  |  sed 's/^[ \t]*//'  |  grep -oP '\s*-D\w+' | sed 's/^[ \t]*//'   | sort  | uniq > temp_f.txt 
		cat temp_f.txt >> ./find_macros_temp.txt
	done

	for i in `find $DIR -type f -iname "*.mk" -print`
	do
		echo ".mk is $i,Header" >> ./find_macros_temp.txt
		grep -n "\-D" $i |  sed 's/^[ \t]*//'  |  grep -oP '\s*-D\w+' | sed 's/^[ \t]*//'   | sort  | uniq > temp_f.txt
		cat temp_f.txt >> ./find_macros_temp.txt
	done

	#find ./ -iname "*makefile*" -print | xargs grep -n "\-D" |  sed 's/^[ \t]*//'  |  grep -oP '\s*-D\w+' | sed 's/^[ \t]*//'   | sort  | uniq > ./find_macros_temp.txt
	#find ./ -iname "*cmake*" -print | xargs grep -n "\-D" |  sed 's/^[ \t]*//'  |  grep -oP '\s*-D\w+' | sed 's/^[ \t]*//'   | sort  | uniq >> ./find_macros_temp.txt
	#find ./ -iname "*.mk" -print | xargs grep -n "\-D" |  sed 's/^[ \t]*//'  |  grep -oP '\s*-D\w+' | sed 's/^[ \t]*//'   | sort  | uniq >> ./find_macros_temp.txt

	cat ./find_macros_temp.txt | sed 's/^[ \t]*//' > make_defined_macros_list.txt

	check_file_and_exit make_defined_macros_list.txt

	rm -f find_macros_temp.txt

	rm -f temp_f.txt
}
create_make_defined_macros_list_fast_path
#======================================================================================================================
