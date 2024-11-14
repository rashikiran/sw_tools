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

#====================================================================================================
# Locks
#	-- spinlock	: Done
#	-- mutex	: Done
#	-- Semaphore	: Done
#
# Contexts
#	-- timer	: Done
#	-- tasklet	: Done
#	-- workqueue	: Done
#	-- softirqs	
#	-- irqs		: Done
#	-- threads
#		-- Kthread threads
#		-- workQueue threads
#		-- IRQ threads
#
# Events/Signals
#	-- 
#
#====================================================================================================
#spin_lock

echo "Extracting spinlocks with \"spin_lock_init\", \"raw_spin_lock_init\", \"DEFINE_SPINLOCK\" ..."

rm -f spin_locks.txt
rm -f contexts.txt

grep -rhw "spin_lock_init" $DIR |  sed 's/^[ \t]*//' | sort | uniq > spin_locks.txt
grep -rhw "raw_spin_lock_init" $DIR |  sed 's/^[ \t]*//' | sort | uniq >> spin_locks.txt
grep -rhw "DEFINE_SPINLOCK" $DIR |  sed 's/^[ \t]*//' | sort | uniq >> spin_locks.txt

echo "------------- SpinLocks -------------" > contexts.txt
cat spin_locks.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "spin_locks.txt") -eq 0 ]; then
    rm -f "spin_locks.txt"
fi
#====================================================================================================
#mutex

echo "Extracting mutex with \"mutex_init\", \"__mutex_init\", \"DEFINE_MUTEX\" ..."

rm -f mutex.txt
grep -rhw "mutex_init" $DIR |  sed 's/^[ \t]*//' | sort | uniq > mutex.txt
grep -rhw "__mutex_init" $DIR |  sed 's/^[ \t]*//' | sort | uniq >> mutex.txt
grep -rhw "DEFINE_MUTEX" $DIR |  sed 's/^[ \t]*//' | sort | uniq >> mutex.txt

echo "------------- Mutex -------------" >> contexts.txt
cat mutex.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "mutex.txt") -eq 0 ]; then
    rm -f "mutex.txt"
fi
#====================================================================================================
#semaphore

echo "Extracting mutex with \"sema_init\", \"DEFINE_SEMAPHORE\" ..."

rm -f semaphore.txt
grep -rhw "sema_init" $DIR |  sed 's/^[ \t]*//' | sort | uniq > semaphore.txt
grep -rhw "DEFINE_SEMAPHORE" $DIR |  sed 's/^[ \t]*//' | sort | uniq >> semaphore.txt

echo "------------- Semaphore -------------" >> contexts.txt
cat semaphore.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "semaphore.txt") -eq 0 ]; then
    rm -f "semaphore.txt"
fi

#====================================================================================================
#timer

echo "Extracting timer with \"timer_setup\", \"timer_setup_on_stack\", \"DEFINE_TIMER\" ..."

rm -f timer.txt
grep -rhw "timer_setup" $DIR |  sed 's/^[ \t]*//' > timer.txt
grep -rhw "timer_setup_on_stack" $DIR |  sed 's/^[ \t]*//' >> timer.txt
grep -rhw "DEFINE_TIMER" $DIR |  sed 's/^[ \t]*//' >> timer.txt

echo "------------- Timer -------------" >> contexts.txt
cat timer.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "timer.txt") -eq 0 ]; then
    rm -f "timer.txt"
fi
#====================================================================================================
#tasklet

echo "Extracting tasklet with \"tasklet_setup\", \"tasklet_init\", \"DECLARE_TASKLET\" ..."

rm -f tasklet.txt
grep -rhw "tasklet_setup" $DIR |  sed 's/^[ \t]*//' > tasklet.txt
grep -rhw "tasklet_init" $DIR |  sed 's/^[ \t]*//' >> tasklet.txt
grep -rhw "DECLARE_TASKLET" $DIR |  sed 's/^[ \t]*//' >> tasklet.txt
grep -rhw "DECLARE_TASKLET_DISABLED" $DIR |  sed 's/^[ \t]*//' >> tasklet.txt
grep -rhw "DECLARE_TASKLET_OLD" $DIR |  sed 's/^[ \t]*//' >> tasklet.txt
grep -rhw "DECLARE_TASKLET_DISABLED_OLD" $DIR |  sed 's/^[ \t]*//' >> tasklet.txt

echo "------------- Tasklet -------------" >> contexts.txt
cat tasklet.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "tasklet.txt") -eq 0 ]; then
    rm -f "tasklet.txt"
fi
#====================================================================================================
#work_queue

echo "Extracting workqueue with \"INIT_WORK\", \"INIT_DELAYED_WORK\" ..."

rm -f work_queue.txt
grep -rhw "INIT_WORK" $DIR |  sed 's/^[ \t]*//' > work_queue.txt
grep -rhw "INIT_DELAYED_WORK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt
grep -rhw "INIT_WORK_ONSTACK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt
grep -rhw "INIT_DELAYED_WORK_ONSTACK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt
grep -rhw "INIT_DEFERRABLE_WORK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt
grep -rhw "INIT_DEFERRABLE_WORK_ONSTACK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt
grep -rhw "INIT_RCU_WORK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt
grep -rhw "INIT_RCU_WORK_ONSTACK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt

grep -rhw "DECLARE_WORK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt
grep -rhw "DECLARE_DELAYED_WORK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt
grep -rhw "DECLARE_DEFERRABLE_WORK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt

echo "------------- work_queue -------------" >> contexts.txt
cat work_queue.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "work_queue.txt") -eq 0 ]; then
    rm -f "work_queue.txt"
fi
#====================================================================================================
#Kthread works
echo "Extracting kthread works..."

rm -f kthread_works.txt
grep -rhw "KTHREAD_WORK_INIT" $DIR |  sed 's/^[ \t]*//' > kthread_works.txt
grep -rhw "KTHREAD_DELAYED_WORK_INIT" $DIR |  sed 's/^[ \t]*//' >> kthread_works.txt
grep -rhw "DEFINE_KTHREAD_WORK" $DIR |  sed 's/^[ \t]*//' >> kthread_works.txt
grep -rhw "DEFINE_KTHREAD_DELAYED_WORK" $DIR |  sed 's/^[ \t]*//' >> kthread_works.txt
grep -rhw "kthread_init_work" $DIR |  sed 's/^[ \t]*//' >> kthread_works.txt
grep -rhw "kthread_init_delayed_work" $DIR |  sed 's/^[ \t]*//' >> kthread_works.txt

echo "------------- kthread works -------------" >> contexts.txt
cat kthread_works.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "kthread_works.txt") -eq 0 ]; then
    rm -f "kthread_works.txt"
fi
#====================================================================================================
# SoftIRQ

#====================================================================================================
# IRQ

echo "Extracting IRQs..."

rm -f irq.txt
grep -rhw "request_irq" $DIR |  sed 's/^[ \t]*//' > irq.txt
grep -rhw "request_threaded_irq" $DIR |  sed 's/^[ \t]*//' >> irq.txt
grep -rhw "request_any_context_irq" $DIR |  sed 's/^[ \t]*//' >> irq.txt
grep -rhw "request_nmi" $DIR |  sed 's/^[ \t]*//' >> irq.txt
grep -rhw "request_percpu_irq" $DIR |  sed 's/^[ \t]*//' >> irq.txt
grep -rhw "request_percpu_nmi" $DIR |  sed 's/^[ \t]*//' >> irq.txt
grep -rhw "devm_request_threaded_irq" $DIR |  sed 's/^[ \t]*//' >> irq.txt
grep -rhw "devm_request_irq" $DIR |  sed 's/^[ \t]*//' >> irq.txt
grep -rhw "devm_request_any_context_irq" $DIR |  sed 's/^[ \t]*//' >> irq.txt

echo "------------- irqs -------------" >> contexts.txt
cat irq.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "irq.txt") -eq 0 ]; then
    rm -f "irq.txt"
fi
#====================================================================================================
#Kthreads
echo "Extracting threads created using kthread APIs..."

rm -f kthreads.txt
grep -rhw "kthread_create_on_node" $DIR |  sed 's/^[ \t]*//' > kthreads.txt
grep -rhw "kthread_create_on_cpu" $DIR |  sed 's/^[ \t]*//' >> kthreads.txt
grep -rhw "kthread_create" $DIR |  sed 's/^[ \t]*//' >> kthreads.txt
grep -rhw "kthread_run" $DIR |  sed 's/^[ \t]*//' >> kthreads.txt
grep -rhw "kthread_run_on_cpu" $DIR |  sed 's/^[ \t]*//' >> kthreads.txt
grep -rhw "kthread_create_worker" $DIR |  sed 's/^[ \t]*//' >> kthreads.txt
grep -rhw "kthread_create_worker_on_cpu" $DIR |  sed 's/^[ \t]*//' >> kthreads.txt

echo "------------- kthread threads -------------" >> contexts.txt
cat kthreads.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "kthreads.txt") -eq 0 ]; then
    rm -f "kthreads.txt"
fi
#====================================================================================================
#workqueue threads
echo "Extracting threads created using workqueue APIs..."

rm -f work_queue_threads.txt
grep -rhw "alloc_ordered_workqueue" $DIR |  sed 's/^[ \t]*//' > work_queue_threads.txt
grep -rhw "create_workqueue" $DIR |  sed 's/^[ \t]*//' >> work_queue_threads.txt
grep -rhw "create_freezable_workqueue" $DIR |  sed 's/^[ \t]*//' >> work_queue_threads.txt
grep -rhw "create_singlethread_workqueue" $DIR |  sed 's/^[ \t]*//' >> work_queue_threads.txt
grep -rhw "alloc_workqueue" $DIR |  sed 's/^[ \t]*//' >> work_queue_threads.txt

echo "------------- workqueue threads -------------" >> contexts.txt
cat work_queue_threads.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "work_queue_threads.txt") -eq 0 ]; then
    rm -f "work_queue_threads.txt"
fi
#====================================================================================================
#IRQ threads
echo "Extracting threads created using IRQ APIs..."

rm -f irq_threads.txt
grep -rhw "request_threaded_irq" $DIR |  sed 's/^[ \t]*//' > irq_threads.txt
grep -rhw "devm_request_threaded_irq" $DIR |  sed 's/^[ \t]*//' >> irq_threads.txt

echo "------------- IRQ threads -------------" >> contexts.txt
cat irq_threads.txt | sort | uniq >> contexts.txt
echo -e "\n" >> contexts.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "irq_threads.txt") -eq 0 ]; then
    rm -f "irq_threads.txt"
fi
#====================================================================================================
