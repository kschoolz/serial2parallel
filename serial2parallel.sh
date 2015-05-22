#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Koh Schooley (kschooley@osc.edu), Ohio Supercomputer Center
#     serial2parallel
#
# This script takes a input command list and runs a certain number of jobs at once.
#
# Commands to be executed must be separated by a newline character within the
# input file.
#
# $MAX_JOBS and $CMD_LIST must be defined for this script to run -- they do not
# default to any sort of default value.  The script will terminate if either is
# not defined.
#
# Usage:
#   serial2parallel <max_proc> <cmd_file>
#
# Where:
#   - max_proc - interger. Maximum number of processes to run at once.
#       Should not exceed maximum number of processors available to job
#       unless you know what your doing.
#
#   - cmd_file - path to file containing commands to run, each on its own line.
#
# ------------------------------------------------------------------------------



# means: run background processes in a separate process and turn on job control...
set -o monitor
# execute add_next_job when we receive a child complete signal
trap add_next_job CHLD

# # Check that CMD_LIST and MAX_JOBS are set, or else exit
# exit_bool=0
# [ -z "$CMD_LIST" ] && echo "Need to set CMD_LIST" && exit_bool=1;
# [ -z "$MAX_JOBS" ] && echo "Need to set MAX_JOBS" && exit_bool=1;
# if [ $exit_bool -eq 1 ];
# then
#     exit 1;
# fi

## Check for valid arguments
# Is the max_proc value a integer?
case $1 in
    ''|*[!0-9]*) echo "max_proc value is not a valid integer value"; echo "terminating"; exit 1 ;;
esac

# Does the file cmd_list exist?
[ ! -f $2 ] && echo "cmd_file does not exist" && exit 1;
 

# Create array from a file, line by line
#IFS=$'\n' read -d '' -r -a cmd_array < $2
#cmd_array=()
#i=0
## Remove left trim, right trim, empty lines, lines w/ only whitespace
#sed 's/^ *//; s/ *$//; /^$/d; /^\s*$/d' $2 | while read line; do
#    cmd_array[$i]=$line
#    echo $line
#    i=$(($i + 1))
#    echo ${cmd_array[$i]}
#done 
#for line in `sed 's/^ *//; s/ *$//; /^$/d; /^\s*$/d' $2`; do
#    cmd_array[$i]="$line"
#    i=$(($i+1))
#done

declare -a cmd_array
i=0
while IFS=$'\n' read -r line; do
    if [[ $line = *[[:space:]]* ]]
    then
       cmd_array[i]=`echo $line | sed 's/^ *//; s/ *$//; /^$/d; /^\s*$/d'`
       ((++i))
    fi
done < $2
# add initial set of jobs
echo index is $index, $ 1 is $1
while [[ $index -lt $1 ]]
do
    echo HIIIII
    add_next_job
done

index=0
function add_next_job {
    # if still jobs to do then add one  
    if [[ $index -lt ${#cmd_array[*]} ]]
    then
        echo adding job ${cmd_array[$index]}
        ${cmd_array[$index]} &
        index=$(($index+1))
    fi
}
# wait for all jobs to complete
wait
