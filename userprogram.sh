#!/bin/bash

function call_for_assistance() {
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
    echo "4. Subscription"
    echo "5. Return to Main Menu"
    read choice

    case $choice in
        1)
            echo "Displaying products..."
            # Placeholder for product viewing logic
            sleep 2
            ;;
        2)
            echo "Checking prices..."
            # Placeholder for price checking logic
            sleep 2
            ;;

        3)
            echo "Proceeding to checkout..."
            # C code for checkout
            sleep 2
            ;;
        
        4)
            echo "Please enter your phone number"
            ;;

        5)
            break
            ;;
        *) echo "Please choose a valid option."
            ;;
    esac


done
