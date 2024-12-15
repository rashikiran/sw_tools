#!/bin/bash

if [ "$1" = "" ];then
        echo "help : ./find.sh <search_dir>"
        exit 1
fi

TDIR=`realpath $1`

DIR=$1

if [ "$TDIR" = "$PWD" ];then
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

sudo rm -f *.txt *.csv *.xlsx

#======================================================================================================================
echo "Compiling tools ..."

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

locks=("SPIN_LOCK,Header" #---------------------------------
	"spin_lock_init"
	"raw_spin_lock_init"
	"DEFINE_SPINLOCK"
	"Mutex,Header" #---------------------------------
	"mutex_init"
	"__mutex_init"
	"DEFINE_MUTEX"
	"Semaphore,Header" #---------------------------------
	"sema_init"
	"DEFINE_SEMAPHORE")

contexts=("TIMER,Header" #---------------------------------
	  "timer_setup"
	  "timer_setup_on_stack"
	  "DEFINE_TIMER"
	  "eloop_register_timeout"
	  "TASKLET,Header" #---------------------------------
	  "tasklet_setup"
	  "tasklet_init"
	  "DECLARE_TASKLET"
	  "DECLARE_TASKLET_DISABLED"
	  "DECLARE_TASKLET_OLD"
	  "DECLARE_TASKLET_DISABLED_OLD"
	  "WORK_QUEUE,Header" #---------------------------------
	  "INIT_WORK"
	  "INIT_DELAYED_WORK"
	  "INIT_WORK_ONSTACK"
	  "INIT_DELAYED_WORK_ONSTACK"
	  "INIT_DEFERRABLE_WORK"
	  "INIT_DEFERRABLE_WORK_ONSTACK"
	  "INIT_RCU_WORK"
	  "INIT_RCU_WORK_ONSTACK"
	  "DECLARE_WORK"
	  "DECLARE_DELAYED_WORK"
	  "DECLARE_DEFERRABLE_WORK"
	  "KTHREAD_WORK,Header" #---------------------------------
	  "KTHREAD_WORK_INIT"
	  "KTHREAD_DELAYED_WORK_INIT"
	  "DEFINE_KTHREAD_WORK"
	  "DEFINE_KTHREAD_DELAYED_WORK"
	  "kthread_init_work"
	  "kthread_init_delayed_work"
	  "IRQ,Header" #---------------------------------
	  "request_irq"
	  "request_threaded_irq"
	  "request_any_context_irq"
	  "request_nmi"
	  "request_percpu_irq"
	  "request_percpu_nmi"
	  "devm_request_threaded_irq"
	  "devm_request_irq"
	  "devm_request_any_context_irq"
	  "KTHREAD,Header" #---------------------------------
	  "kthread_create_on_node"
	  "kthread_create_on_cpu"
	  "kthread_create"
	  "kthread_run"
	  "kthread_run_on_cpu"
	  "kthread_create_worker"
	  "kthread_create_worker_on_cpu"
	  "WORK_QUEUE_THREAD,Header" #---------------------------------
	  "alloc_ordered_workqueue"
	  "create_workqueue"
	  "create_freezable_workqueue"
	  "create_singlethread_workqueue"
	  "alloc_workqueue"
	  "IRQ_THREAD,Header" #---------------------------------
	  "request_threaded_irq"
	  "devm_request_threaded_irq")

data_structures=("SLIST_INIT" "STAILQ_INIT" "LIST_INIT" "TAILQ_INIT" "CIRCLEQ_INIT" "INIT_LIST_HEAD" "LIST_HEAD_INIT" "skb_queue_head_init" "__skb_queue_head_init" "DEFINE_HASHTABLE" "DEFINE_READ_MOSTLY_HASHTABLE" "DECLARE_HASHTABLE" "dl_list_init")

ipcs=("wpa_supplicant_event" "socket")

create_csv()
{
	sudo rm -f $1.txt $1.csv

	check_file_and_exit temp.txt

        sed -i 's/\([^:]*:[^:]*\):[[:space:]]*\([[:print:]]\)/\1:\2/' temp.txt
	sed -i 's/[[:space:]]*$//'  temp.txt
        cat temp.txt  | grep -v '\"' | grep -v '^*' | grep -v "#include" | uniq >> $1.txt
        
	echo ",,,,,," >> $1.csv
        
	awk -F':' '{ print $1 "," $2 "," $3 }' $1.txt  >> $1.csv

        # Check if file size is 0 bytes
        if [ $(stat -c %s "$1.txt") -eq 0 ]; then
            sudo rm -f "$1.txt" "$1.csv"
        fi
}

search_pattern()
{
	sudo rm -f temp.txt

        echo "Extracting \"$1\" ... "

	array_name="$1"
	eval "selected_array=(\"\${$array_name[@]}\")"

	for pattern in "${selected_array[@]}";
	do
		x=`echo $pattern | grep -i "Header"`
		if [ "$x" ];
		then
			echo "Header cell found .... $pattern"
			echo $pattern >> temp.txt
		else
			echo "Searching for $pattern ...."
			find $DIR -iname "*.[ch]" -print | xargs grep -nw "$pattern" |  sed 's/^[ \t]*//' | grep -v '^*' | uniq >> temp.txt
		fi
	done

	sed -i 's/[[:space:]]*$//'  temp.txt
}

#====================================================================================================
create_locks_csv()
{
	search_pattern "locks"
	create_csv "locks"
	check_file_and_exit "locks.csv"
}
create_locks_csv
#====================================================================================================
create_contexts_csv()
{
	search_pattern "contexts"
	create_csv "contexts"
	check_file_and_exit "contexts.csv"
}
create_contexts_csv
#====================================================================================================
create_data_structures_csv()
{
	search_pattern "data_structures"
	create_csv "data_structures"
	check_file_and_exit "data_structures.csv"
}
create_data_structures_csv
#====================================================================================================
create_ipcs_csv()
{
	search_pattern "ipcs"
	create_csv "ipcs"
	check_file_and_exit "ipcs.csv"
}
create_ipcs_csv
#====================================================================================================
combine_csvs()
{
	check_file_and_exit ./combine_csvs.py
	python3 ./combine_csvs.py $DIR.xlsx
	check_file_and_exit $DIR.xlsx
}
combine_csvs
#====================================================================================================
insert_rows_n_cols_in_csv()
{
	check_file_and_exit ./insert_rows_n_cols_in_csv.py
	python3 ./insert_rows_n_cols_in_csv.py $DIR.xlsx
	check_file_and_exit $DIR.xlsx
}
insert_rows_n_cols_in_csv
#====================================================================================================
merge_first_row_in_csv()
{
	check_file_and_exit ./merge_first_row_in_csv.py
	python3 ./merge_first_row_in_csv.py $DIR.xlsx
	check_file_and_exit $DIR.xlsx
}
merge_first_row_in_csv
#====================================================================================================
merge_headers_in_csv()
{
	check_file_and_exit ./merge_headers.py
	python3 ./merge_headers.py $DIR.xlsx
	check_file_and_exit $DIR.xlsx
}
merge_headers_in_csv
#libreoffice $DIR.xlsx
#====================================================================================================
