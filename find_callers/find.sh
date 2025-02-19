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
echo "Removing old results ..."

rm -f ./find_fun_def
rm -f ./remove_c_comments
rm -f ./fun_call_list.txt
rm -f ./fun_def_list.txt
rm -f ./macros_def_list.txt
rm -f ./res_compiler_attributes.txt
rm -f ./res_fun_called_but_not_defined_list.txt
#======================================================================================================================
echo "Compiling tools ..."

check_file_and_exit ./find_fun_def.c
cc find_fun_def.c -o find_fun_def
check_file_and_exit ./find_fun_def

check_file_and_exit ./remove_c_comments.c
cc remove_c_comments.c -o remove_c_comments
check_file_and_exit ./remove_c_comments
#======================================================================================================================
echo "Preprocessing : Removing all single line strings ..."

check_dir_and_exit $DIR

for i in `find $DIR -iname "*.[ch]" -print`;
do
	sed -i 's/"[^"]*"/""/g' "$i"
done
#======================================================================================================================
echo "Preprocessing : Removing all single line comments ..."

check_dir_and_exit $DIR

# Find all .c and .h files recursively in the current directory.
find $DIR -type f \( -name "*.c" -o -name "*.h" \) | while read -r file; do
    # Use sed to remove only single-line comments.
    sed -i 's|//.*||g' "$file"
    #echo "Processed: $file"
done
#======================================================================================================================
echo "Preprocessing : Removing all multi line comments ..."

check_dir_and_exit $DIR
check_file_and_exit ./remove_c_comments

for i in `find $DIR -iname "*.[ch]" -print`;
do
	./remove_c_comments $i
	if [ $? -ne 0 ];then
		echo "./remove_c_comments failed"
		exit 1
	fi
done

#======================================================================================================================
# Creates fun_call_list.txt
echo "Creating v1.0 of fun_call_list.txt ..."
rm -f fun_call_list.txt
rm -f temp.txt

check_dir_and_exit $DIR

for i in `find $DIR -iname "*.[ch]" -print`;
do
	egrep -o '\b[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(' $i | sed 's/[[:space:]]*(//' >> temp.txt
done

cat temp.txt | sort | uniq > fun_call_list.txt

check_file_and_exit ./fun_call_list.txt
#======================================================================================================================
# Creates fun_def_list.txt
echo "Creating v1.0 of fun_def_list.txt ..."

rm -f temp.txt

check_dir_and_exit $DIR
check_file_and_exit ./fun_call_list.txt
check_file_and_exit ./find_fun_def

for fun_name in `cat fun_call_list.txt`;
do
	#echo "Checking function $fun_name"
	#TODO: Consider passing $i only for whole words
	for file_name in `find $DIR -iname "*.[ch]" -print | xargs grep -lw $fun_name`;
	do
		x=`grep -w  $fun_name $file_name |  grep -v ";" | grep -v "="`
		if [ "$x" ];then
			echo $fun_name > t_fun.txt
			./find_fun_def $file_name t_fun.txt >> temp.txt
			if [ $? -ne 0 ];then
				echo "./find_fun_def failed"
				exit 1
			fi
		fi
	done
#	sleep 1
done

rm -f t_fun.txt

cat temp.txt | sort | uniq > fun_def_list.txt

check_file_and_exit ./fun_def_list.txt
#======================================================================================================================
#TODO : combine nm output with above fun_def_list.txt

#======================================================================================================================
# Creates res_fun_called_but_not_defined_list.txt

echo "Creating v1.0 of res_fun_called_but_not_defined_list.txt ..."

rm -f res_fun_called_but_not_defined_list.txt
rm -f temp.txt

check_file_and_exit ./fun_call_list.txt
check_file_and_exit ./fun_def_list.txt

for line in `cat fun_call_list.txt`
do
    x=`grep -w $line fun_def_list.txt`
    if [ ! "$x" ];
    then
            echo "$line" >> temp.txt 
    fi	
done

cat temp.txt | sort | uniq > res_fun_called_but_not_defined_list.txt

check_file_and_exit ./res_fun_called_but_not_defined_list.txt
#======================================================================================================================
# res_fun_called_but_not_defined_list.txt still has function_calls which are actually macros
# we need to consider them as defined. Hence, needs to be filtered from res_fun_called_but_not_defined_list.txt

echo "Creating v1.0 of macros_def_list.txt ..."

rm -f temp.txt
rm -f macros_def_list.txt

check_dir_and_exit $DIR

for i in `find $DIR -iname "*.[ch]" -print`;
do
        grep "#define " $i >> macros_def_list.txt
done

check_file_and_exit ./macros_def_list.txt

filename=macros_def_list.txt

# Read the file line by line
while IFS= read -r line; do
    # Check if the line starts with #define
    if [[ $line == \#define* ]]; then
        # Extract the second word using awk and trim spaces using xargs
        word=$(echo "$line" | awk '{print $2}' | xargs)
        
        # Remove any trailing "(...)" pattern using sed to extract only the part before '(' if it exists
        word=$(echo "$word" | sed 's/(.*//')

        # Output the cleaned-up word
        echo "$word" >> temp.txt

        # Additional check for words surrounded by complex expressions, extract only the second word
        if [[ "$word" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
            # If the word is already clean, output it directly
            echo "$word" >> temp.txt
        else
            # Otherwise, clean up and extract only the identifier (second word)
            cleaned_word=$(echo "$line" | awk '{print $2}' | sed 's/[(].*//')
            echo "$cleaned_word" >> temp.txt
        fi
    fi	
done < "$filename"

cat temp.txt | sort | uniq > macros_def_list.txt

check_file_and_exit ./macros_def_list.txt
#===================================================================================================================
# Now explicilty check for #define of every line in res_fun_called_but_not_defined_list.txt

echo "Creating v1.1 of res_fun_called_but_not_defined_list.txt : Removing macros listed as function definitions ..."

rm -f temp.txt

check_file_and_exit ./res_fun_called_but_not_defined_list.txt
check_file_and_exit ./macros_def_list.txt

for line in `cat res_fun_called_but_not_defined_list.txt`
do
    x=`grep -w $line macros_def_list.txt`
    if [ ! "$x" ];
    then
            echo "$line" >> temp.txt 
    fi	
done

cat temp.txt | sort | uniq > res_fun_called_but_not_defined_list.txt

rm -f temp.txt

for line in `cat res_fun_called_but_not_defined_list.txt`
do
        x=`find $DIR -iname "*.[ch]" -print | xargs grep -rniw $line | grep "#define"`
        if [ ! "$x" ];
        then
                echo "$line" >> temp.txt
        fi
done

cat temp.txt | sort | uniq > res_fun_called_but_not_defined_list.txt

check_file_and_exit ./res_fun_called_but_not_defined_list.txt
#===================================================================================================================
# Remove any whole words like if, for , while, switch listed as functions
echo "Creating v1.2 of res_fun_called_but_not_defined_list.txt : Removing C keywords listed as function calls ..."

rm -f temp.txt

check_file_and_exit ./res_fun_called_but_not_defined_list.txt

cat res_fun_called_but_not_defined_list.txt | grep -vw "for" | grep -vw "while" | grep -vw "if" | grep -vw "switch"|  grep -vw "int" | grep -vw "char" | grep -vw "float" | grep -vw "double" | grep -vw "bool" | grep -vw "sizeof" | grep -vw "ssize_t" | grep -vw "u8" | grep -vw "u16"  | grep -vw "u32" | grep -vw "u64" | grep -vw "case" | grep -vw "size_t" | grep -vw "s8" | grep -vw "s16"  | grep -vw "s32" | grep -vw "s64"  | grep -vw "return" | grep -vw "void" > temp.txt

cat temp.txt | sort | uniq > res_fun_called_but_not_defined_list.txt

check_file_and_exit ./res_fun_called_but_not_defined_list.txt
#===================================================================================================================
# Remove any whole words compiler attributes listed as functions

echo "Creating v1.3 of res_fun_called_but_not_defined_list.txt : Removing Compiler attributes listed as function calls ..."

rm -f temp.txt

check_file_and_exit ./res_fun_called_but_not_defined_list.txt

cat res_fun_called_but_not_defined_list.txt | grep -vw "aligned" | grep -vw "__aligned" |  grep -vw "__aligned__" | grep -vw "__alignof__" | grep -vw "__attribute__" | grep -vw "likely"  | grep -vw "__acquire" | grep -vw "__acquires" | grep -vw "__builtin_choose_expr" | grep -vw "__builtin_constant_p" | grep -vw "__cond_lock" | grep -vw "__dynamic_array" | grep -vw "__field" | grep -vw "__get_dynamic_array" | grep -vw "__get_str" | grep -vw "__release" | grep -vw "__releases" | grep -vw "__section" | grep -vw "unlikely" | grep -vw "__stringify" | grep -vw "__assign_str" | grep -vw "__string" | grep -vw "__builtin_clz" | grep -vw "__get_unaligned_cpu32" > temp.txt

grep -w "aligned" ./res_fun_called_but_not_defined_list.txt > res_compiler_attributes.txt
grep -w "__aligned" ./res_fun_called_but_not_defined_list.txt > res_compiler_attributes.txt
grep -w "__aligned__" ./res_fun_called_but_not_defined_list.txt > res_compiler_attributes.txt
grep -w "__alignof__" ./res_fun_called_but_not_defined_list.txt > res_compiler_attributes.txt
grep -w "__attribute__" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "likely" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__acquire" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__acquires" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__builtin_choose_expr" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__builtin_constant_p" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__cond_lock" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__dynamic_array" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__field" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__get_dynamic_array" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__get_str" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__release" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__releases" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__section" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "unlikely" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__stringify" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__assign_str" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__string" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__builtin_clz" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt
grep -w "__get_unaligned_cpu32" ./res_fun_called_but_not_defined_list.txt >> res_compiler_attributes.txt

cat temp.txt | sort | uniq > res_fun_called_but_not_defined_list.txt

check_file_and_exit ./res_fun_called_but_not_defined_list.txt
#===================================================================================================================
# Remove any whole words like C preprocessor keywords listed as functions

echo "Creating v1.4 of res_fun_called_but_not_defined_list.txt : Removing C Preprocessor keywords listed as function calls ..."

rm -f temp.txt

check_dir_and_exit $DIR
check_file_and_exit ./res_fun_called_but_not_defined_list.txt

x=`cat res_fun_called_but_not_defined_list.txt | grep -w "defined"`

if [ "$x" ];then
	x=`find $DIR -iname "*.[ch]" -print | xargs grep -rniw "defined"  | grep -v "#if"`

	if [ ! "$x" ];then

		cat res_fun_called_but_not_defined_list.txt | grep -vw "defined" > temp.txt

		cat temp.txt | sort | uniq > res_fun_called_but_not_defined_list.txt
	fi
fi

check_file_and_exit ./res_fun_called_but_not_defined_list.txt

#===================================================================================================================
