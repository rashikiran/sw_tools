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
echo "Enable permissions for \"$DIR\" ..."

sudo chmod 0777 -R *
#======================================================================================================================
echo "Compiling tools ..."

check_file_and_exit ./remove_c_comments.c
cc remove_c_comments.c -o remove_c_comments
check_file_and_exit ./remove_c_comments
#======================================================================================================================
remove_single_line_strings()
{
	echo "Preprocessing : Removing all single line strings ..."

	check_dir_and_exit $DIR

	for i in `find $DIR -iname "*.[ch]" -print`;
	do
        	sed -i 's/"[^"]*"/""/g' "$i"
	done
}
#remove_single_line_strings
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

locks=("Linux SPIN_LOCK,Header" #---------------------------------
	"spin_lock_init"
	"raw_spin_lock_init"
	"DEFINE_SPINLOCK"
	"Linux MUTEX,Header" #---------------------------------
	"mutex_init"
	"__mutex_init"
	"DEFINE_MUTEX"
	"Linux Semaphore,Header" #---------------------------------
	"sema_init"
	"DEFINE_SEMAPHORE"
	"Free-BSD MUTEX,Header" #---------------------------------
	"mtx_init"
	"Linux APPLICATION_Locks,Header" #---------------------------------
	"g_mutex_init"
	"pthread_mutex_init")

contexts=("Linux KERNEL_TIMER,Header" #---------------------------------
	  "timer_setup"
	  "timer_setup_on_stack"
	  "DEFINE_TIMER"
	  "Linux APPLICATION_TIMER,Header" #---------------------------------
	  "eloop_register_timeout"
	  "setitimer"
	  "Linux Processes,Header" #---------------------------------
	  "fork"
	  "vfork"
	  "execl"
	  "execlp"
	  "execv"
	  "execve"
	  "execvp"
	  "Linux Pipe Processes,Header" #---------------------------------
	  "popen"
	  "Linux Gthreads,Header" #---------------------------------
	  "g_thread_create"
	  "Linux Pthreads,Header" #---------------------------------
	  "pthread_create"
	  "Linux TASKLET,Header" #---------------------------------
	  "tasklet_setup"
	  "tasklet_init"
	  "DECLARE_TASKLET"
	  "DECLARE_TASKLET_DISABLED"
	  "DECLARE_TASKLET_OLD"
	  "DECLARE_TASKLET_DISABLED_OLD"
	  "Linux WORK_QUEUE,Header" #---------------------------------
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
	  "Linux KTHREAD_WORK,Header" #---------------------------------
	  "KTHREAD_WORK_INIT"
	  "KTHREAD_DELAYED_WORK_INIT"
	  "DEFINE_KTHREAD_WORK"
	  "DEFINE_KTHREAD_DELAYED_WORK"
	  "kthread_init_work"
	  "kthread_init_delayed_work"
	  "Linux IRQ,Header" #---------------------------------
	  "request_irq"
	  "request_threaded_irq"
	  "request_any_context_irq"
	  "request_nmi"
	  "request_percpu_irq"
	  "request_percpu_nmi"
	  "devm_request_threaded_irq"
	  "devm_request_irq"
	  "devm_request_any_context_irq"
	  "Linux KTHREAD,Header" #---------------------------------
	  "kthread_create_on_node"
	  "kthread_create_on_cpu"
	  "kthread_create"
	  "kthread_run"
	  "kthread_run_on_cpu"
	  "kthread_create_worker"
	  "kthread_create_worker_on_cpu"
	  "Linux WORK_QUEUE_THREAD,Header" #---------------------------------
	  "alloc_ordered_workqueue"
	  "create_workqueue"
	  "create_freezable_workqueue"
	  "create_singlethread_workqueue"
	  "alloc_workqueue"
	  "Linux IRQ_THREAD,Header" #---------------------------------
	  "request_threaded_irq"
	  "devm_request_threaded_irq"
	  "Free-BSD Kthreads,Header" #---------------------------------
	  "kproc_create"
	  "Free-BSD TaskQ threads,Header" #---------------------------------
	  "taskqueue_create"
	  "Free-BSD TaskQ jobs,Header" #---------------------------------
	  "TASK_INIT"
	  "Free-BSD Timers,Header" #---------------------------------
	  "callout_reset")

data_structures=("Singly-linked List,Header" #---------------------------------
		"SLIST_INIT"
		"Singly-linked Tail queue,Header" #---------------------------------
		"STAILQ_INIT"
		"LInked List,Header" #---------------------------------
		"ListInitialize"
		"LIST,Header" #---------------------------------
		"LIST_INIT"
		"TAILQ,Header" #---------------------------------
		"TAILQ_INIT"
		"CIRCULAR QUEUE,Header" #---------------------------------
		"CIRCLEQ_INIT"
		"Circular doubly linked list,Header" #---------------------------------
		"INIT_LIST_HEAD"
		"LIST_HEAD_INIT"
		"SKB QUEUE,Header" #---------------------------------
		"skb_queue_head_init"
		"__skb_queue_head_init"
		"HASH TABLE,Header" #---------------------------------
		"DEFINE_HASHTABLE"
		"DEFINE_READ_MOSTLY_HASHTABLE"
		"DECLARE_HASHTABLE"
		"DOUBLY LINKED LIST,Header" #---------------------------------
		"dl_list_init"
		"malloc Allocations,Header" #---------------------------------
		"malloc"
		"calloc Allocations,Header" #---------------------------------
		"calloc"
		"realloc Allocations,Header" #---------------------------------
		"realloc"
		"g_malloc Allocations,Header" #---------------------------------
		"g_malloc"
		"g_malloc0"
		"g_malloc0_n"
		"g_realloc_n Allocations,Header" #---------------------------------
		"g_realloc_n"
		"json_node_alloc Allocations,Header" #---------------------------------
		"json_node_alloc"
		"wpabuf Allocations,Header" #---------------------------------
		"wpabuf_alloc"
		"os_malloc Allocations,Header" #---------------------------------
		"os_malloc"
		"os_calloc Allocations,Header" #---------------------------------
		"os_calloc"
		"os_zalloc Allocations,Header" #---------------------------------
		"os_zalloc"
		"g_datalist,Header" #---------------------------------
		"g_datalist_init"
		"g_hash_table,Header" #---------------------------------
		"g_hash_table_new")

events=("WPA_SUPPLICANT_EVENT,Header" #---------------------------------
	"wpa_supplicant_event"
	"Linux Completion Variables,Header" #---------------------------------
	"DECLARE_COMPLETION"
	"DECLARE_COMPLETION_ONSTACK"
	"DECLARE_COMPLETION_ONSTACK_MAP"
	"init_completion"
	"Linux Wait Queues,Header" #---------------------------------
	"DECLARE_WAITQUEUE"
	"DECLARE_WAIT_QUEUE_HEAD"
	"init_waitqueue_head"
	"DECLARE_WAIT_QUEUE_HEAD_ONSTACK"
	"DEFINE_WAIT"
	"init_wait"
	"Linux SWAIT Queues,Header" #---------------------------------
	"DECLARE_SWAITQUEUE"
	"DECLARE_SWAIT_QUEUE_HEAD"
	"init_swait_queue_head"
	"DECLARE_SWAIT_QUEUE_HEAD_ONSTACK"
	"Linux SWAIT Queues,Header" #---------------------------------
	"Linux DBUS Signals,Header"
	"dbus_message_new_signal"
	"Linux select events,Header" #---------------------------------
	"select"
	"Linux pselect events,Header" #---------------------------------
	"pselect"
	"Linux poll events,Header" #---------------------------------
	"poll"
	"Linux ppoll events,Header" #---------------------------------
	"ppoll"
	"Linux epoll_wait events,Header" #---------------------------------
	"epoll_wait")

ipcs=("SOCKET,Header" #---------------------------------
      "socket"
      "Linux Shared Memory,Header" #---------------------------------
      "shm_open"
      "Linux Message Queues,Header" #---------------------------------
      "msgget"
      "Linux fopen,Header" #---------------------------------
      "fopen"
      "Linux open,Header" #---------------------------------
      "open"
      "Linux g_fopen,Header" #---------------------------------
      "g_fopen"
      "Linux opendir,Header" #---------------------------------
      "opendir"
      "Linux g_io_channel_unix_new,Header" #---------------------------------
      "g_io_channel_unix_new")

HW=("Hardware Details,Header") #---------------------------------

SW_src=("Source Files,Header") #---------------------------------

SW_hdrs=("External Header Files,Header") #---------------------------------

SW_bins=("Binary Files List,Header") #---------------------------------

SW_bin_OS_symbols=("OS Symbol dependencies from NM,Header") #---------------------------------

fun_calls=("fun calls,Header") #---------------------------------

fun_defs=("fun defs,Header") #---------------------------------

create_csv()
{
	sudo rm -f $1.txt $1.csv

	check_file_and_exit find_aggr_temp.txt

        sed -i 's/\([^:]*:[^:]*\):[[:space:]]*\([[:print:]]\)/\1:\2/' find_aggr_temp.txt
	sed -i 's/[[:space:]]*$//'  find_aggr_temp.txt
        #cat find_aggr_temp.txt  | grep -v '\"' | grep -v '^*' | grep -v "#include" | uniq >> $1.txt
        cat find_aggr_temp.txt | grep -v '^*' | grep -v "#include" | uniq >> $1.txt
        
	echo ",,,,,,,,,,,,,,,,,,,," >> $1.csv
        
	awk -F':' '{ print $1 "," $2 "," $3 }' $1.txt  >> $1.csv

        # Check if file size is 0 bytes
        if [ $(stat -c %s "$1.txt") -eq 0 ]; then
            sudo rm -f "$1.txt" "$1.csv"
        fi
}

search_pattern()
{
	sudo rm -f find_aggr_temp.txt

        echo "Extracting \"$1\" ... "

	array_name="$1"
	eval "selected_array=(\"\${$array_name[@]}\")"

	for pattern in "${selected_array[@]}";
	do
		x=`echo $pattern | grep -i "Header"`
		if [ "$x" ];
		then
			echo "Header cell found .... $pattern"
			echo $pattern >> find_aggr_temp.txt
		else
			echo "Searching for $pattern ...."
			find $DIR -iname "*.[ch]" -print | xargs grep -nw "$pattern" |  sed 's/^[ \t]*//' | grep -v '^*' | uniq | grep -i "$pattern(">> find_aggr_temp.txt
		fi
	done

	sed -i 's/[[:space:]]*$//'  find_aggr_temp.txt
}

main_search_categories=("locks"
                        "contexts"
                        "data_structures"
                        "ipcs"
                        "events"
                        "HW"
                        "SW_src"
                        "SW_hdrs"
                        "SW_bins"
                        "SW_bin_OS_symbols"
                        "fun_calls"
                        "fun_defs"
			"SW_conditional_macros"
			"SW_defined_macros"
			"SW_make_defined_macros")

locks_action()
{
	search_pattern "locks"
	create_csv "locks"
	check_file_and_exit "locks.csv"
}			

contexts_action()
{
	search_pattern "contexts"
	create_csv "contexts"
	check_file_and_exit "contexts.csv"
}

data_structures_action()
{
	search_pattern "data_structures"
	create_csv "data_structures"
	check_file_and_exit "data_structures.csv"
}

ipcs_action()
{
	search_pattern "ipcs"
	create_csv "ipcs"
	check_file_and_exit "ipcs.csv"
}

events_action()
{
	search_pattern "events"
	create_csv "events"
	check_file_and_exit "events.csv"
}

HW_action()
{
	echo "Extracting \"HW\" ... "

	sudo rm -f find_aggr_temp.txt

	for pattern in "${HW[@]}";
	do
		x=`echo $pattern | grep -i "Header"`
		if [ "$x" ];
		then
			echo "Header cell found .... $pattern"
			echo $pattern >> find_aggr_temp.txt
		fi
	done

	sed -i 's/[[:space:]]*$//'  find_aggr_temp.txt

	create_csv "HW"

	check_file_and_exit "HW.csv"
}

SW_src_action()
{
	echo "Extracing \"SW_src\" ..."

	sudo rm -f find_aggr_temp.txt

	echo "$DIR,Header"  >> find_aggr_temp.txt

	for i in `ls $DIR`;
	do
		if [ -d "$DIR/$i" ];
		then
			echo "$DIR/$i,Header"  >> find_aggr_temp.txt
			find $DIR/$i >> find_aggr_temp.txt
		fi

		if [ -f "$DIR/$i" ];
		then
			echo $DIR/$i >> find_aggr_temp.txt
		fi
	done

	sed -i 's/[[:space:]]*$//'  find_aggr_temp.txt

	create_csv "SW_src"

	check_file_and_exit "SW_src.csv"
}

SW_hdrs_action()
{
	echo "Extracting \"SW_hdrs\" ..."

	sudo rm -f find_aggr_temp.txt

	echo "$DIR Hdrs,Header"  >> find_aggr_temp.txt

	for i in `ls $DIR`;
	do
		if [ -d "$DIR/$i" ];
		then
			check_file_and_exit ./find_headers.sh
			./find_headers.sh $DIR/$i

			echo "$DIR/$i Internal Hdrs,Header"  >> find_aggr_temp.txt

			find $DIR/$i -iname "*.h" -print >> find_aggr_temp.txt

			echo "$DIR/$i External Hdrs,Header"  >> find_aggr_temp.txt
			check_file_and_exit res_include_headers_file_not_found_list.txt
			cat res_include_headers_file_not_found_list.txt >> find_aggr_temp.txt
		fi

		if [ -f "$DIR/$i" ];
		then
			if [[ "$DIR/$i" == *.h ]]; then
				echo $DIR/$i >> find_aggr_temp.txt
			fi
		fi
	done

	sed -i 's/[[:space:]]*$//'  find_aggr_temp.txt

	create_csv "SW_hdrs"

	check_file_and_exit "SW_hdrs.csv"
}

SW_bins_action()
{
	echo "Extracting \"SW_bins\" ..."
}

SW_bin_OS_symbols_action()
{
	echo "Extracing \"SW_bin_OS_symbols\" ..."
}

fun_defs_action()
{
	echo "Extracting \"fun_defs_action\" ..."

	sudo rm -f find_aggr_temp.txt

	check_file_and_exit ./find_defs.sh

	x=`find $DIR -mindepth 1 -type d | wc -l`
	if [ "$x" -eq "0" ];then
		echo "Checking fun defs in dir \"$DIR\" ..."
		./find_defs.sh $DIR

		echo "$DIR fun defs,Header"  >> find_aggr_temp.txt
		cat ./fun_def_list.txt >> find_aggr_temp.txt
	else
		for i in `ls $DIR`;
		do
			if [ -d "$DIR/$i" ];
			then
				echo "Checking fun defs in dir \"$DIR/$i\" ..."
				./find_defs.sh $DIR/$i

				echo "$DIR/$i fun defs,Header"  >> find_aggr_temp.txt
				cat ./fun_def_list.txt >> find_aggr_temp.txt
			fi
		done
	fi

	check_file_and_exit find_aggr_temp.txt

	sed -i 's/[[:space:]]*$//'  find_aggr_temp.txt

	create_csv "fun_defs"

	check_file_and_exit "fun_defs.csv"
}

fun_calls_action()
{
	echo "Extracting \"fun_calls_action\" ..."

	sudo rm -f find_aggr_temp.txt

	check_file_and_exit ./find_callers.sh

	x=`find $DIR -mindepth 1 -type d | wc -l`
	if [ "$x" -eq "0" ];then
		echo "Checking fun calls in dir \"$DIR\" ..."
		./find_callers.sh $DIR
		echo "$DIR fun calls,Header"  >> find_aggr_temp.txt
		cat res_fun_called_but_not_defined_list.txt >> find_aggr_temp.txt
	else
		for i in `ls $DIR`;
		do
			if [ -d "$DIR/$i" ];
			then
				echo "Checking fun calls in dir \"$DIR/$i\" ..."
				./find_callers.sh $DIR/$i

				echo "$DIR/$i fun calls,Header"  >> find_aggr_temp.txt

				cat res_fun_called_but_not_defined_list.txt >> find_aggr_temp.txt
			fi
		done
	fi

	check_file_and_exit find_aggr_temp.txt

	sed -i 's/[[:space:]]*$//'  find_aggr_temp.txt

	create_csv "fun_calls"

	check_file_and_exit "fun_calls.csv"
}

SW_conditional_macros_action()
{
	echo "Extracting \"SW_conditional_macros\" ..."

	sudo rm -f find_aggr_temp.txt

	./find_conditional_macros.sh $DIR

	check_file_and_exit ./conditional_macros_list.txt

	cat ./conditional_macros_list.txt >> find_aggr_temp.txt

	check_file_and_exit find_aggr_temp.txt

	sed -i 's/[[:space:]]*$//'  find_aggr_temp.txt

	create_csv "SW_conditional_macros"

	check_file_and_exit "SW_conditional_macros.csv"
}

SW_defined_macros_action()
{
	echo "Extracting \"SW_defined_macros\" ..."

	sudo rm -f find_aggr_temp.txt

	./find_defined_macros.sh $DIR

	check_file_and_exit ./defined_macros_list.txt

	cat ./defined_macros_list.txt >> find_aggr_temp.txt

	check_file_and_exit find_aggr_temp.txt

	sed -i 's/[[:space:]]*$//'  find_aggr_temp.txt

	create_csv "SW_defined_macros"

	check_file_and_exit "SW_defined_macros.csv"
}

SW_make_defined_macros_action()
{
	echo "Extracting \"SW_make_defined_macros\" ..."

	sudo rm -f find_aggr_temp.txt

	./find_make_defined_macros.sh $DIR

	check_file_and_exit ./make_defined_macros_list.txt

	cat ./make_defined_macros_list.txt >> find_aggr_temp.txt

	check_file_and_exit find_aggr_temp.txt

	sed -i 's/[[:space:]]*$//'  find_aggr_temp.txt

	create_csv "SW_make_defined_macros"

	check_file_and_exit "SW_make_defined_macros.csv"
}

start_analysis()
{
	for main_category in "${main_search_categories[@]}";
	do

		"$main_category"_"action"
	done
}
start_analysis
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
