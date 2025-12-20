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
    echo "8. Generate Zombie and Orphan Processes"
    echo "9. Kill all Zombie and Orphan Processes"
    echo "10. Logout"
    read option

    case $option in
        1) ;;
        2) ;;
        3) ;;
        4) ;;
        5) 
            ps -ef | grep -E "main_menu.sh|userprogram.sh|adminprogram.sh|daemon_stock_monitor.sh|generatezombie|generateorphan" | grep -v grep
            read -p "Press Enter to continue..."
            ;;
        6) ;;
        7) ;;
        8) 
            ./generatezombie &
            ./generateorphan &
            echo -e "\n[INFO] Zombie and Orphan processes generated in the background."
            read -p "Press Enter to continue..."
            ;;
        9) 
            # Kill Zombie Processes and Orphan Processes
            # Get parent PIDs of zombie processes
            zombie_parents=$(ps -ef | grep "<defunct>" | grep -v grep | awk '{print $3}' | sort -u) # Parent PIDs of zombies
            # grep "<defunct>" finds zombie processes
            # grep -v grep excludes the grep command itself
            # awk '{print $3}' extracts their parent PIDs
            # we sort -u to avoid killing the same parent multiple times
            if [ -z "$zombie_parents" ]; then
                echo -e "\n[INFO] No zombie processes found."
            else
                kill -9 $zombie_parents > /dev/null 2>&1
                echo -e "\n[INFO] Killed all zombie processes."
            fi

            # Get PIDs of orphan processes
            
            orphan_pids=$(ps -ef | grep "generateorphan" | grep -v grep | awk -v main_pid=$$ '$3 != main_pid {print $2}')
            # grep "generateorphan" finds orphan processes
            # grep -v grep excludes the grep command itself
            # awk: Pass the current script's PID ($$) into awk as 'main_pid'.
            # '$3 != main_pid': Look at the 3rd column (Parent PID). If it's NOT our script, it's an orphan.
            # '{print $2}': Output the 2nd column (The orphan's actual Process ID) to the variable.
            if [ -z "$orphan_pids" ]; then
                echo -e "\n[INFO] No orphan processes found."
            else
                kill -9 $orphan_pids > /dev/null 2>&1
                echo -e "\n[INFO] Killed all orphan processes."
            fi

            read -p "Press Enter to continue..."
            
            ;;
        10)
            break
            ;;

        *)
            echo -e "\n[ERROR] Invalid option. Please try again."
            ;;

    esac


done