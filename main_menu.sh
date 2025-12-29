#!/bin/bash
LOG_FILE="./system_logs.txt"
# Creating a main menu for Supermarket OS
# This script will display a simple text-based menu

# --- BOOT SEQUENCE: START DAEMONS ---
echo "Booting Supermarket OS..."

# Check if the daemon script exists
if [ -f "./daemon_stock_monitor.sh" ]; then
    # 1. Kill any old instances so we don't have duplicates running
    pkill -f "daemon_stock_monitor.sh"
    
    # 2. Launch in Background (Daemon Mode)
    # nohup: Keeps it running even if terminal closes
    # > /dev/null: Silences output (daemons shouldn't speak to screen)
    # 2>&1: Silences error as well (error goes to same place as output)
    # &: Puts it in background
    nohup ./daemon_stock_monitor.sh > /dev/null 2>&1 &
    
    # 3. Save the Process ID (PID) so we can kill it later
    DAEMON_PID=$!
    echo " [OK] Stock Watchdog Service started (PID: $DAEMON_PID)"
    sleep 1
else
    echo " [ERROR] stock_daemon.sh not found!"
fi

sleep 1 # Just for effect

log_action() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    # Appends the log entry to the file
    echo "[$timestamp] [Main Menu] $message" >> "$LOG_FILE"
}

login_user() {
    local username=$1
    local password=$2
    # Dummy authentication logic for demonstration
    if  grep -q "$username:$password" ./admins.txt 
    then
        clear
        log_action "[$username] Performed Login"
        echo "Login successful! Welcome, $username."
        sleep 2
        ./adminprogram.sh
    else
        log_action "[$username] Failed Login"
        echo "Login failed! Invalid username or password."
    fi
}

while true
clear
do
    echo "===================================="
    echo "      Supermarket OS Login Menu     "
    echo "===================================="

    echo "1. User"
    echo "2. Admin"
    echo "3. Exit"
    read choice

    case $choice in
        1)
            log_action "Performed Login"
            ./userprogram.sh
            ;;
        2) 
            echo -e "Please Enter your username:\n"
            read username
            echo -e "Please Enter your password:\n"
            read -s password
            login_user $username $password
            ;;
        3)  
            log_action "Exitted Supermarket OS"
            pkill -f daemon_stock_monitor.sh
            # 'kill 0' sends a kill signal to every process in the current "Process Group".
            # Since your main menu launched the daemon, they are in the same group.
            echo "Shutting down Supermarket OS..."
            kill -9 -$$
            ;;
        *) echo "Please choose a valid option."
            ;;
    esac
    
    echo "Press any button to continue..."
    read temp

done

done