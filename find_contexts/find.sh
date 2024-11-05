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

# Locks
#	-- spinlock
#	-- mutex
#	-- Semaphore
#
# Contexts
#	-- timer
#	-- tasklet
#	-- workqueue
#	-- softirqs
#	-- irqs
#	-- threads
#
# Events/Signals
#	-- 
#
#

#====================================================================================================
#spin_lock_init

echo "Extracting spinlocks with \"spin_lock_init\" ..."

rm -f spin_locks.txt
rm -f contexts.txt

grep -rhw "spin_lock_init" $DIR |  sed 's/^[ \t]*//' | sort | uniq > spin_locks.txt

echo "------------- SpinLocks -------------" > contexts.txt

cat spin_locks.txt | sort | uniq >> contexts.txt

echo -e "\n" >> contexts.txt
#====================================================================================================
#mutex_init

echo "Extracting mutex with \"mutex_init\" ..."

rm -f mutex.txt

grep -rhw "mutex_init" $DIR |  sed 's/^[ \t]*//' | sort | uniq > mutex.txt

echo "------------- Mutex -------------" >> contexts.txt

cat mutex.txt | sort | uniq >> contexts.txt

echo -e "\n" >> contexts.txt
#====================================================================================================
#sema_init

echo "Extracting mutex with \"sema_init\" ..."

rm -f semaphore.txt

grep -rhw "sema_init" $DIR |  sed 's/^[ \t]*//' | sort | uniq > semaphore.txt

echo "------------- Mutex -------------" >> contexts.txt

cat semaphore.txt | sort | uniq >> contexts.txt

echo -e "\n" >> contexts.txt
#====================================================================================================
#timer_setup

echo "Extracting timer with \"timer_setup\", \"DEFINE_TIMER\" ..."

rm -f timer.txt

echo "------------- Timer -------------" >> contexts.txt

echo -e "\n" >> contexts.txt

grep -rhw "timer_setup" $DIR |  sed 's/^[ \t]*//' > timer.txt

grep -rhw "DEFINE_TIMER" $DIR |  sed 's/^[ \t]*//' >> timer.txt

cat timer.txt | sort | uniq >> contexts.txt

echo -e "\n" >> contexts.txt
#====================================================================================================
#timer_setup

echo "Extracting tasklet with \"tasklet_setup\", \"DECLARE_TASKLET\" ..."

rm -f tasklet.txt

grep -rhw "tasklet_setup" $DIR |  sed 's/^[ \t]*//' > tasklet.txt

echo "------------- Tasklet -------------" >> contexts.txt

cat tasklet.txt | sort | uniq >> contexts.txt

echo -e "\n" >> contexts.txt
#====================================================================================================
#work_queue

echo "Extracting workqueue with \"INIT_WORK\", \"INIT_DELAYED_WORK\" ..."

rm -f work_queue.txt

grep -rhw "INIT_WORK" $DIR |  sed 's/^[ \t]*//' > work_queue.txt
grep -rhw "INIT_DELAYED_WORK" $DIR |  sed 's/^[ \t]*//' >> work_queue.txt

echo "------------- work_queue -------------" >> contexts.txt

cat work_queue.txt | sort | uniq >> contexts.txt

echo -e "\n" >> contexts.txt
#====================================================================================================
