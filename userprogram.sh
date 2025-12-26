#!/bin/bash

call_for_assistance() {
    echo -e "\n\n!!! EMERGENCY ASSISTANCE REQUESTED !!!"
    echo "Alerting Store Manager..."
    
    # Send a signal (SIGUSR1) to the Admin Program
    # This satisfies "Process communication through signals"
    pkill -SIGUSR1 -f "adminprogram.sh" # Send SIGUSR1 to adminprogram.sh process
    
    echo "Manager has been notified."
    sleep 2
    
    # Reprint the menu so the user isn't lost
    echo -e "\nReturning to menu..."
}

trap call_for_assistance SIGINT

display_products() {
    
    if [ ! -f "inventory.txt" ]; then
        echo "[ERROR] Inventory file not found!"
        return
    fi
    
    echo -e "Items are viewed in this format \n"
    echo -e "\nID\t| NAME\t| STOCK\t| PRICE\n"
    echo "----------------------------------------------------"
    # IFS=':' tells Bash to split the line at the colons
    while IFS=':' read -r id name quantity price
    do
        # Skip empty lines
        if [ -z "$id" ]; then
            continue
        fi

        printf "%s\t| %s\t| %s\t| $%.2f\n" "$id" "$name" "$quantity" "$price"
    done < inventory.txt

    read -p "Press Enter to continue..."
}


while true
do
    clear
    echo "===================================="
    echo "        Supermarket OS User Menu     "
    echo "===================================="
    echo " (Press Ctrl+C at any time for Help)"
    echo "------------------------------------"

    echo "1. View Products"
    echo "2. Price Check"
    echo "3. Check Out"
    echo "4. Return to Main Menu"
    read choice

    case $choice in
        1)
            echo "Displaying products..."
            # Placeholder for product viewing logic
            sleep 2
            display_products
            ;;
        2)
            sleep 2
            ./pricecheck
            ;;

        3)
            echo "Proceeding to checkout..."
            sleep 2
            ./checkout
            ;;
        
        4)
            break
            ;;

        *) echo "Please choose a valid option."
            ;;
    esac


done
