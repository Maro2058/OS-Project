#!/bin/bash

handle_sigint() {
    echo -e "\nGoing back to admin program..."
    sleep 2
    exit 0
}
trap handle_sigint SIGINT

log_file="./system_logs.txt"

    if [ -f $log_file ]
    then
        echo "Tracking log file: $log_file"
        echo "Press Ctrl+C to go back to admin program."
        sleep 3
        tail -f $log_file
    else
        echo "Log file '$log_file' does not exist."
    fi