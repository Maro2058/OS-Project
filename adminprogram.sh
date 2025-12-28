#!/bin/bash


handle_alert() {
    echo -e "\n[ALERT] A Customer has requested emergency assistance!"
}

addItem(){
    read -p "Enter ID: " ID
    read -p "Enter Name: " Name
    read -p "Enter Quantity: " Quantity
    read -p "Enter Price: " Price

    # Regex to check the following:
        # ID is an integer
        # Quanitity is an integer
        # Price is a float
    if [[ "$ID" =~ [0-9]+$ ]] && [[ "$Quantity" =~ [0-9]+$ ]] && [[ "$Price" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        echo "$ID:$Name:$Quantity:$Price" >> inventory.txt
    else
        echo -e "Invalid Input. Please make sure
            1. ID is unique and an integer
            2. Quantity is an integer
            3. Price is a float"
    fi

}

# Searches by name or ID
InventorySearch(){

    local -n result="$1"

    read -p "Enter Name or ID of item you want to find: (Optional) " input

    # Collect all matches (ID OR Name) into an array according to grep (-t without new line)
    # first "<": takes input
    # second "<(...) treats function output as a file"
    mapfile -t matches < <(grep -Ei "^$input|^[^:]*:$input" inventory.txt)

    # No matches
    if (( ${#matches[@]} == 0 )); then
        echo "No matching items found."
        return
    fi

    # Matches found. Prints them out
    echo "Matches found:"
    for i in "${!matches[@]}"; do
        printf "%d) %s\n" "$((i+1))" "${matches[i]}"
    done

    # Lets user pick
    while true; do
        read -p "Select item number (0 to cancel): " choice
        if [ "$choice" -eq 0 ]; then
            break
        elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#matches[@]} )); then
            result="${matches[choice-1]}"
            break
        else
            echo "Invalid selection."
        fi
    done
}

removeItem() {

    InventorySearch result

    # stream editor (in-place edit) sed delimiter/pattern/replacement where / is a delimiter
    # \| = uses | as delimeter since its a rare character. Backslash so it is passed literally instead of as regex
    # ^...$ means exact match. ^ = start of line, $ = end of line
    # ${matches[choice-1]} = The line we want to delete
    # |d = delete
    sed -i "\|^${result}$|d" inventory.txt
    echo "Item removed: ${result}"
}

restockItem(){
    
    InventorySearch result

    read -p "Enter New stock to add: " Increment

    id="${result%%:*}"   # Extract ID

    # Edits the folder and changes the quantity
    # awk [options] 'pattern {action}' input-file > output-file
    # options:
        # -i inplace -> inplace editing
        # -F: -> custom field seperator to ":"
        # -v -> Assigs variables before execution
    # pattern {action}:
        # BEGIN -> Runs before input lines are processed
        # { OFS=":"} -> Output Field Seperator. Output of the command different from -F which is for input to the command.
        # $1 == id { $3 = qty }. If first field is the same ID, set the quantity to the new quantity
        # { print } each line
    awk -i inplace -F: -v id="$id" -v qty="$Increment" '
    BEGIN { OFS=":" }
    $1 == id { $3 = $3 + qty }
    { print }
    ' inventory.txt
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
    echo "10. Return to Main Menu"
    read option


    case $option in
        1) 
            addItem
        ;;
        2) 
            removeItem
        ;;
        3) 
            InventorySearch temp
            echo $temp
        
        ;;
        4) 
            restockItem
        ;;
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

    echo "Press any button to continue..."
    read temp

done