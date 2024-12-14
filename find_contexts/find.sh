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

rm -f *.txt *.csv

linux_kernel_spin_lock=("spin_lock_init" "raw_spin_lock_init" "DEFINE_SPINLOCK")
linux_kernel_mutex=("mutex_init" "__mutex_init" "DEFINE_MUTEX")
linux_kernel_semaphores=("sema_init" "DEFINE_SEMAPHORE")
linux_kernel_timers=("timer_setup" "timer_setup_on_stack" "DEFINE_TIMER")
linux_kernel_tasklets=("tasklet_setup" "tasklet_init" "DECLARE_TASKLET" "DECLARE_TASKLET_DISABLED" "DECLARE_TASKLET_OLD" "DECLARE_TASKLET_DISABLED_OLD")
linux_kernel_work_queues=("INIT_WORK" "INIT_DELAYED_WORK" "INIT_WORK_ONSTACK" "INIT_DELAYED_WORK_ONSTACK" "INIT_DEFERRABLE_WORK" "INIT_DEFERRABLE_WORK_ONSTACK" "INIT_RCU_WORK" "INIT_RCU_WORK_ONSTACK" "DECLARE_WORK" "DECLARE_DELAYED_WORK" "DECLARE_DEFERRABLE_WORK")
linux_kernel_kthread_works=("KTHREAD_WORK_INIT" "KTHREAD_DELAYED_WORK_INIT" "DEFINE_KTHREAD_WORK" "DEFINE_KTHREAD_DELAYED_WORK" "kthread_init_work" "kthread_init_delayed_work")
linux_kernel_irqs=("request_irq" "request_threaded_irq" "request_any_context_irq" "request_nmi" "request_percpu_irq" "request_percpu_nmi" "devm_request_threaded_irq" "devm_request_irq" "devm_request_any_context_irq")
linux_kernel_kthreads=("kthread_create_on_node" "kthread_create_on_cpu" "kthread_create" "kthread_run" "kthread_run_on_cpu" "kthread_create_worker" "kthread_create_worker_on_cpu")
linux_kernel_work_queue_threads=("alloc_ordered_workqueue" "create_workqueue" "create_freezable_workqueue" "create_singlethread_workqueue" "alloc_workqueue")
linux_kernel_irq_threads=("request_threaded_irq" "devm_request_threaded_irq")
eloop_timers=("eloop_register_timeout")
wpa_supplicant_events=("wpa_supplicant_event")
sockets=("socket(" "socket (")

create_csv()
{
        echo "Extracting \"$1\" ... "

        sed -i 's/\([^:]*:[^:]*\):[[:space:]]*\([[:print:]]\)/\1:\2/' temp.txt
        cat temp.txt  | grep -v '\"' | grep -v '^*' | sort | uniq > $1.txt
        awk -F':' '{ print $1 "," $2 "," $3 }' $1.txt  > $1.csv
        rm -f temp.txt

        echo "------------- $1 -------------" >> contexts.txt
        cat $1.txt | sort | uniq | grep -v '^*' >> contexts.txt
        echo -e "\n" >> contexts.txt

        # Check if file size is 0 bytes
        if [ $(stat -c %s "$1.txt") -eq 0 ]; then
            rm -f "$1.txt" "$1.csv"
        fi
}

search_pattern()
{
	rm -f temp.txt

	array_name="$1"
	eval "selected_array=(\"\${$array_name[@]}\")"

	for pattern in "${selected_array[@]}";
	do
		find $DIR -iname "*.[ch]" -print | xargs grep -ni "$pattern" |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' >> temp.txt
	done
}

#====================================================================================================
#spin_lock
create_linux_kernel_spin_lock_csv()
{
	search_pattern "linux_kernel_spin_lock"
	create_csv "linux_kernel_spin_lock"
}
create_linux_kernel_spin_lock_csv

#====================================================================================================
#mutex
create_linux_kernel_mutex_csv()
{
	search_pattern "linux_kernel_mutex"
	create_csv "linux_kernel_mutex"
}
create_linux_kernel_mutex_csv
#====================================================================================================
#semaphore
create_linux_kernel_semaphore_csv()
{
	search_pattern "linux_kernel_semaphores"
	create_csv "linux_kernel_semaphores"
}
create_linux_kernel_semaphore_csv
#====================================================================================================
#timer
create_linux_kernel_timer_csv()
{
	search_pattern "linux_kernel_timers"
	create_csv "linux_kernel_timers"
}
create_linux_kernel_timer_csv
#====================================================================================================
#tasklet

create_linux_kernel_tasklet_csv()
{
	search_pattern "linux_kernel_tasklets"
	create_csv "linux_kernel_tasklets"
}
create_linux_kernel_tasklet_csv
#====================================================================================================
#work_queue
create_linux_kernel_work_queues_csv()
{
	search_pattern "linux_kernel_work_queues"
	create_csv "linux_kernel_work_queues"
}
create_linux_kernel_work_queues_csv
#====================================================================================================
#Kthread works
create_linux_kernel_kthread_works_csv()
{
	search_pattern "linux_kernel_kthread_works"
	create_csv "linux_kernel_kthread_works"
}
create_linux_kernel_kthread_works_csv
#====================================================================================================
# SoftIRQ

#====================================================================================================
# IRQ
create_linux_kernel_irqs_csv()
{
	search_pattern "linux_kernel_irqs"
	create_csv "linux_kernel_irqs"
}
create_linux_kernel_irqs_csv
#====================================================================================================
#Kthreads
create_linux_kernel_kthreads_csv()
{
	search_pattern "linux_kernel_kthreads"
	create_csv "linux_kernel_kthreads"
}
create_linux_kernel_kthreads_csv
#====================================================================================================
#workqueue threads
create_linux_kernel_work_queue_threads_csv()
{
	search_pattern "linux_kernel_work_queue_threads"
	create_csv "linux_kernel_work_queue_threads"
}
create_linux_kernel_work_queue_threads_csv
#====================================================================================================
#IRQ threads
create_linux_kernel_irq_threads_usage_list_csv()
{
	search_pattern "linux_kernel_irq_threads"
	create_csv "linux_kernel_irq_threads"
}
create_linux_kernel_irq_threads_usage_list_csv
#====================================================================================================
#Eloop timers
create_eloop_timers_usage_list_csv()
{
	search_pattern "eloop_timers"
	create_csv "eloop_timers"
}
create_eloop_timers_usage_list_csv
#====================================================================================================
#wpa supplicant events
create_wpa_supplicant_events_csv()
{
	search_pattern "wpa_supplicant_events"
	create_csv "wpa_supplicant_events"
}
create_wpa_supplicant_events_csv
#====================================================================================================
#sockets list
create_sockets_csv()
{
	search_pattern "sockets"
	create_csv "sockets"
}
create_sockets_csv
#====================================================================================================
