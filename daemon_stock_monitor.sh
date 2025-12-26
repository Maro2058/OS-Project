#!/bin/bash

# Daemon script to monitor stock quantity and send alerts
LOG_FILE="./system_logs.txt"
LOW_STOCK_ITEMS="./low_stock_items.txt"
cutoff=5

# 1. Safety Checks
# Make sure inventory file exists
if [ ! -f ./inventory.txt ]
then
    echo "Inventory file not found."
    exit 1
fi

# Create Low Stock items file if it doesn't exist
if [ ! -f "$LOW_STOCK_ITEMS" ]
then
    touch "$LOW_STOCK_ITEMS"
fi

echo "Stock Daemon Started..." >> "$LOG_FILE"

# 2. The Infinite Daemon Loop
while true
do
    tempfile=$(mktemp)

    # Read the inventory file line by line
    # We feed the file into the loop at the very bottom using '<'
    while IFS=':' read -r id name quantity price
    do
    now=$(date "+%H:%M:%S")
        # Skip empty lines to prevent errors
        if [ -z "$id" ]; then continue; fi

        # 3. The Condition (Check if quantity < 5)
        if [ "$quantity" -lt $cutoff ]; then
            if ! grep -q "^$id:$name:" "$LOW_STOCK_ITEMS"; then
                # Log only because it's a NEW alert
                echo "[$now] ALERT: Low stock for '$name' | $quantity left." >> "$LOG_FILE"
                echo "$id:$name:$quantity:$price" >> "$LOW_STOCK_ITEMS" 
            fi
        # Check if quantity > 5)
        elif [ "$quantity" -ge $cutoff ]; then
            # If item is in Low stock items
            if  grep -q "^$id:$name" "$LOW_STOCK_ITEMS" ; then
                echo "[$now] INFO: $name restocked" >> "$LOG_FILE"
                grep -v "^$id:$name" "$LOW_STOCK_ITEMS" > "$tempfile" && mv "$tempfile" "$LOW_STOCK_ITEMS"
            fi
        fi
    done < ./inventory.txt  # <--- This feeds the file into the inner loop

    # Sleep for 5 seconds before checking again
    sleep 5

    rm -f "$tempfile"
done
