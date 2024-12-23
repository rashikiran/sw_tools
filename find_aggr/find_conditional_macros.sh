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
remove_single_line_comments_in_c_files()
{
        echo "Preprocessing : Removing all single line comments ..."

        check_dir_and_exit $DIR

        # Find all .c and .h files recursively in the current directory.
        find $DIR \( -iname "*.[ch]" -o -iname "*.[ch]pp" \) -print | while read -r file; do
            # Use sed to remove only single-line comments.
            sed -i 's|//.*||g' "$file"
            #echo "Processed: $file"
        done
}
remove_single_line_comments_in_c_files
#======================================================================================================================
echo "Preprocessing : Removing all multi line comments ..."
remove_multi_line_comments_in_c_files()
{
        check_dir_and_exit $DIR
        check_file_and_exit ./remove_c_comments

        for i in `find $DIR \( -iname "*.[ch]" -o -iname "*.[ch]pp" \) -print`;
        do
                ./remove_c_comments $i
                if [ $? -ne 0 ];then
                        echo "./remove_c_comments failed"
                        exit 1
                fi
        done
}
remove_multi_line_comments_in_c_files
#======================================================================================================================
extract_conditional_macros()
{
	rm -f conditional_macros_list.txt

	echo "Extract_conditional_macros ..."

	check_dir_and_exit $DIR

	for i in `find $DIR \( -iname "*.[ch]" -o -iname "*.[ch]pp" \) -print`;
	do
		#Remove all spaces at the start of every line a file
		sed -i 's/^[ \t]*//' "$i"
		#Remove all spaces between '#' and 'ifdef'
		sed -i 's/#\s*ifdef/#ifdef/' "$i"		
		#Extract #ifdef
		sed -i '/^#ifdef[ \t]\+[a-zA-Z_][a-zA-Z0-9_]*[ \t]\+/s/.*//'  "$i"

		#Remove all spaces between '#' and 'ifndef'
		sed -i 's/#\s*ifndef/#ifndef/' "$i"		
		#Extract #ifdef
		sed -i '/^#ifndef[ \t]\+[a-zA-Z_][a-zA-Z0-9_]*[ \t]\+/s/.*//'  "$i"

		sed -i 's/^#ifdef[[:space:]]\+/#ifdef /' "$i"
		sed -i 's/^#ifndef[[:space:]]\+/#ifndef /' "$i"
		sed -i 's/^#if[[:space:]]\+/#if /' "$i"
	done

	grep -rni "#ifdef " $DIR | cut -f 3 -d ":"  | cut -f 2 -d " " | sort | uniq > conditional_macros_list.txt

	dos2unix conditional_macros_list.txt

	#Remove all lines not starting with a-z, A-Z, _
	sed -i '/^[^a-zA-Z_]/d' conditional_macros_list.txt

	#Remove all blank lines
	sed -i '/^[[:space:]]*$/d' conditional_macros_list.txt

	#Remove all characters after /
	sed -i 's/\/.*//' conditional_macros_list.txt

	#Remove all characters after $
	sed -i 's/\$.*//' conditional_macros_list.txt

	#Remove all characters after ,
	sed -i 's/,.*//' conditional_macros_list.txt

	cat conditional_macros_list.txt | sort | uniq > find_conditional_macros_temp.txt

	cp find_conditional_macros_temp.txt conditional_macros_list.txt

	check_file_and_exit conditional_macros_list.txt

	rm -f find_conditional_macros_temp.txt
}
extract_conditional_macros
#======================================================================================================================
