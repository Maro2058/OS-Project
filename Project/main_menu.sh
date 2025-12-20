#!/bin/bash

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

login_user() {
    local username=$1
    local password=$2
    # Dummy authentication logic for demonstration
    if  grep -q "$username:$password" ./admins.txt 
    then
        echo "Login successful! Welcome, $username."
        ./adminprogram.sh
    else
        echo "Login failed! Invalid username or password."
    fi
}

while true
do
    clear
    echo "===================================="
    echo "      Supermarket OS Login Menu     "
    echo "===================================="

    echo "1. User"
    echo "2. Admin"
    echo "3. Exit"
    read choice

    case $choice in
        1)
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
            pkill -f daemon_stock_monitor.sh
            # 'kill 0' sends a kill signal to every process in the current "Process Group".
            # Since your main menu launched the daemon, they are in the same group.
            echo "Shutting down Supermarket OS..."
            kill 0
            ;;
        *) echo "Please choose a valid option."
            ;;
    esac

done

done