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
echo "Preprocessing : Removing all single line strings .."

rm -f find_headers_temp.txt

temp_file="find_headers_temp.txt"

check_dir_and_exit $DIR

grep -rh "#include" $DIR | sort | uniq > include_headers_list_unprocessed.txt

check_file_and_exit ./include_headers_list_unprocessed.txt

filename=include_headers_list_unprocessed.txt

# Read the file line by line
while IFS= read -r line; do
    # Check if the line starts with #include
    if [[ $line == \#include* ]]; then
        # Extract the second word (header file) using awk
        word=$(echo "$line" | awk '{print $2}' | xargs)

        # Remove surrounding < and > if present, as well as any trailing "(...)"
        word=$(echo "$word" | sed -e 's/[<>]//g' -e 's/(.*//' | xargs)

        # Remove surrounding double quotes, if any
        word=$(echo "$word" | sed 's/^"//; s/"$//')

        # Validate the cleaned word, allowing letters, numbers, underscores, dots, and slashes
        if [[ "$word" =~ ^[A-Za-z0-9_/.\-]+$ ]]; then
            echo "$word" >> "$temp_file"
        else
            # Additional cleaning: Remove any characters except letters, numbers, underscores, dots, and slashes
            cleaned_word=$(echo "$word" | sed 's/[^A-Za-z0-9_/.\-]//g')
            echo "$cleaned_word" >> "$temp_file"
        fi
    fi
done < "$filename"

cat find_headers_temp.txt | sort | uniq > ./include_headers_list_unprocessed.txt

check_file_and_exit ./include_headers_list_unprocessed.txt
#======================================================================================================================

rm -f ./res_include_headers_file_found_list.txt
rm -f ./res_include_headers_file_not_found_list.txt

check_file_and_exit ./include_headers_list_unprocessed.txt

filename=include_headers_list_unprocessed.txt

# Read the file line by line
while IFS= read -r header_name; do
	
	x=`dirname $header_name`
	if [ "$x" = "." ];then
		x=`find $DIR -iname "*$header_name*"`
		if [ "$x" ];then
			echo $header_name >> res_include_headers_file_found_list.txt
		else
			echo $header_name >> res_include_headers_file_not_found_list.txt
		fi
	else
		# $header_name = a/b/c/file.h
		only_header_name=`basename $header_name` # file.h
		path_of_header_name=`dirname $header_name`    # a/b/c
		parent_of_header_name=`basename $path_of_header_name` # c
		x=`find $DIR -iname "*$parent_of_header_name*" -type d`
		if [ "$x" ];then
			x=`find $x -iname "*$only_header_name*" -print`
			if [ "$x" ];then
				echo $header_name >> res_include_headers_file_found_list.txt
			else
				echo $header_name >> res_include_headers_file_not_found_list.txt
			fi
		else
			echo $header_name >> res_include_headers_file_not_found_list.txt
		fi
	fi

done < "$filename"

cat res_include_headers_file_found_list.txt | sort | uniq > find_headers_temp.txt

cat find_headers_temp.txt > res_include_headers_file_found_list.txt

cat res_include_headers_file_not_found_list.txt | sort | uniq > find_headers_temp.txt

cat find_headers_temp.txt > res_include_headers_file_not_found_list.txt

rm -f find_headers_temp.txt

check_file_and_exit res_include_headers_file_found_list.txt

check_file_and_exit res_include_headers_file_not_found_list.txt
#======================================================================================================================
