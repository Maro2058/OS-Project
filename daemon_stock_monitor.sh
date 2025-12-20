#!/bin/bash

# Daemon script to monitor stock quantity and send alerts
LOG_FILE="./system_logs.txt"
LOW_STOCK_ITEMS="./low_stock_items.txt"

# 1. Safety Check
if [ ! -f ./inventory.txt ]
then
    echo "Inventory file not found."
    exit 1
fi

if [ ! -f "$LOW_STOCK_ITEMS" ]
then
    touch "$LOW_STOCK_ITEMS"
fi

echo "Stock Daemon Started..." >> "$LOG_FILE"

# 2. The Infinite Daemon Loop
while true
do
    # Read the inventory file line by line
    # We feed the file into the loop at the very bottom using '<'
    while IFS=':' read -r id name quantity
    do
        # Skip empty lines to prevent errors
        if [ -z "$id" ]; then continue; fi

        # 3. The Condition (Check if quantity < 5)
        if [ "$quantity" -lt 5 ]; then
            
            if ! grep -q "^$id:$name:" "$LOW_STOCK_ITEMS"; then
                
                now=$(date "+%H:%M:%S")
                
                # Log only because it's a NEW alert
                echo "[$now] ALERT: Low stock for '$name'! Only $quantity left." >> "$LOG_FILE"
                echo "$id:$name:$quantity" >> "$LOW_STOCK_ITEMS" 
            fi
        fi
    done < ./inventory.txt  # <--- This feeds the file into the inner loop

    # Sleep for 5 seconds before checking again
    sleep 5
done
