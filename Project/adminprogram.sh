#!/bin/bash


handle_alert() {
    echo -e "\n[ALERT] A Customer has requested emergency assistance!"
}

trap handle_alert SIGUSR1

while true
do

    clear
    echo "========================================"
    echo "   STORE ADMIN DASHBOARD (Logged In)"
    echo "========================================"
    echo "1. View System Logs (History)"
    echo "2. Manage Users/Employees"
    echo "3. Manage Products (Inventory)"
    echo "4. Manage Shifts (Schedule)"
    echo "5. SYSTEM MONITOR (Processes) [Tech Req]"
    echo "6. WAREHOUSE STATUS (Disk/Mem) [Tech Req]"
    echo "7. EMERGENCY STOP (Signal Broadcast)"
    echo "8. Logout"

    read option

    case $option in
        
    esac


done