#!/bin/bash

# Creating a main menu for Supermarket OS
# This script will display a simple text-based menu



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
    #clear
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
        3)  #pkill -f stock_monitor_daemon.sh
            exit 0
            ;;
        *) echo "Please choose a valid option."
            ;;
    esac

done

done