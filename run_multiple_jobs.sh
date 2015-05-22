#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Koh Schooley (kschooley@osc.edu), Ohio Supercomputer Center
#     serial2parallel
#
# Much of this code is taken/derived from http://stackoverflow.com/a/6594537
#
# This script takes a input command list ($CMD_LIST) and runs a certain number
# of jobs ($MAX_JOBS) at once.
#
# Commands to be executed must be separated by a newline character within
# $CMD_LIST.
#
# $MAX_JOBS and $CMD_LIST must be defined for this script to run -- they do not
# default to any sort of default value.  The script will terminate if either is
# not defined.
# ------------------------------------------------------------------------------

set -o monitor
# means: run background processes in a separate processes...
trap add_next_job CHLD
# execute add_next_job when we receive a child complete signal

# Check that CMD_LIST and MAX_JOBS are set, or else exit
exit_bool=0
[ -z "$CMD_LIST" ] && echo "Need to set CMD_LIST" && exit_bool=1;
[ -z "$MAX_JOBS" ] && echo "Need to set MAX_JOBS" && exit_bool=1;
if [ $exit_bool -eq 1 ];
then
    exit 1;
fi

# Create array from a file, line by line
IFS=$'\n' read -d '' -r -a cmd_array < $CMD_LIST

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

# add initial set of jobs
while [[ $index -lt $MAX_JOBS ]]
do
    add_next_job
done

# wait for all jobs to complete
wait
