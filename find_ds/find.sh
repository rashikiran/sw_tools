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

rm -f data_structures.txt

#====================================================================================================
# Data Structures
#	-- LIST	:
#====================================================================================================
#Singly-linked list

echo "Extracting Singly-linked List with slists ... "

rm -f slists.txt

grep -rhw "SLIST_INIT" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' > slists.txt

echo "------------- Singly-linked List -------------" >> data_structures.txt
cat slists.txt | sort | uniq >> data_structures.txt
echo -e "\n" >> data_structures.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "slists.txt") -eq 0 ]; then
    rm -f "slists.txt"
fi
#====================================================================================================
#Singly-linked Tail queue

echo "Extracting Singly-linked Tail queues with stailq... "

rm -f stailq.txt

grep -rhw "STAILQ_INIT" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' > stailq.txt

echo "------------- Singly-linked Tail queue -------------" >> data_structures.txt
cat stailq.txt | sort | uniq >> data_structures.txt
echo -e "\n" >> data_structures.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "stailq.txt") -eq 0 ]; then
    rm -f "stailq.txt"
fi
#====================================================================================================
# Lists

echo "Extracting lists with LIST... "

rm -f list.txt

grep -rhw "LIST_INIT" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' > list.txt

echo "------------- LIST -------------" >> data_structures.txt
cat list.txt | sort | uniq >> data_structures.txt
echo -e "\n" >> data_structures.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "list.txt") -eq 0 ]; then
    rm -f "list.txt"
fi
#====================================================================================================
# tailq

echo "Extracting tailqs with TAILQ ... "

rm -f tailq.txt

grep -rhw "TAILQ_INIT" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' > tailq.txt

echo "------------- TAILQ -------------" >> data_structures.txt
cat tailq.txt | sort | uniq >> data_structures.txt
echo -e "\n" >> data_structures.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "tailq.txt") -eq 0 ]; then
    rm -f "tailq.txt"
fi
#====================================================================================================
# Circular queue

echo "Extracting Circular queue with CIRCLEQ ... "

rm -f circleq.txt

grep -rhw "CIRCLEQ_INIT" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' > circleq.txt

echo "------------- CIRCLEQ -------------" >> data_structures.txt
cat circleq.txt | sort | uniq >> data_structures.txt
echo -e "\n" >> data_structures.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "circleq.txt") -eq 0 ]; then
    rm -f "circleq.txt"
fi
#====================================================================================================
# Circular doubly linked list

echo "Extracting Circular doubly linked list with INIT_LIST_HEAD ... "

rm -f circular_dll.txt

grep -rhw "INIT_LIST_HEAD" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' > circular_dll.txt
grep -rhw "LIST_HEAD_INIT" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' >> circular_dll.txt

echo "------------- Circular doubly linked list -------------" >> data_structures.txt
cat circular_dll.txt | sort | uniq >> data_structures.txt
echo -e "\n" >> data_structures.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "circular_dll.txt") -eq 0 ]; then
    rm -f "circular_dll.txt"
fi
#====================================================================================================
# SKB Queues

echo "Extracting SKB Queues  ... "

rm -f skb_queue.txt

grep -rhw "skb_queue_head_init" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' > skb_queue.txt
grep -rhw "__skb_queue_head_init" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' >> skb_queue.txt

echo "------------- SKB Queues -------------" >> data_structures.txt
cat skb_queue.txt | sort | uniq >> data_structures.txt
echo -e "\n" >> data_structures.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "skb_queue.txt") -eq 0 ]; then
    rm -f "skb_queue.txt"
fi
#====================================================================================================
# Hash Tables

echo "Extracting Hash Tables  ... "

rm -f hash_tables.txt

grep -rhw "DEFINE_HASHTABLE" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' > hash_tables.txt
grep -rhw "DEFINE_READ_MOSTLY_HASHTABLE" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' >> hash_tables.txt
grep -rhw "DECLARE_HASHTABLE" $DIR |  sed 's/^[ \t]*//' | sort | uniq |  grep -v '^*' >> hash_tables.txt

echo "------------- HASH Tables -------------" >> data_structures.txt
cat hash_tables.txt | sort | uniq >> data_structures.txt
echo -e "\n" >> data_structures.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "hash_tables.txt") -eq 0 ]; then
    rm -f "hash_tables.txt"
fi
#====================================================================================================
echo "Extracting dl lists  ... "

rm -f dl_lists.txt

grep -rhw "dl_list_init" $DIR |  sed 's/^[ \t]*//' |  sort | uniq  | grep -v '^*' > dl_lists.txt

echo "------------- DL Lists -------------" >> data_structures.txt
cat dl_lists.txt | sort | uniq >> data_structures.txt
echo -e "\n" >> data_structures.txt

# Check if file size is 0 bytes
if [ $(stat -c %s "dl_lists.txt") -eq 0 ]; then
    rm -f "dl_lists.txt"
fi
#====================================================================================================
