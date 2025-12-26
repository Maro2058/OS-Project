#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>


int main(){
    long long int id; // Item ID input by user
    char line[200]; // Buffer to read lines from inventory file
    int found = 0; // Flag to check if item is found

    printf("\nEnter Item ID: "); 
    scanf("%lld", &id);  // scans input

    FILE *file = fopen("inventory.txt", "r"); // Open inventory file
        // Error handling for file open
        if (file == NULL) {
            perror("Failed to open inventory file");
            return 1;
        }

    
    while (fgets(line, sizeof(line), file)) {
            long long int item_id; // Variables to hold parsed data
            char item_name[100]; // Assuming max name length is 99
            int item_quantity; // Quantity of the item
            float item_price; // Price of the item
            // the %["^:"] specifier reads a string until a colon is encountered, cuz some names may have spaces
            sscanf(line, "%lld:%[^:]:%d:%f", &item_id, item_name, &item_quantity, &item_price);
            if (item_id == id) { // Match found
                printf("Item Name: %s\nItem Price: %.2f\n", item_name, item_price);
                found = 1; // Set found flag
                break; // Exit the loop early
            }

        }
        
        fclose(file); // Close the file
        if (!found) {
            printf("Item ID %lld not found in inventory.\n", id); // Notify user that item not found
        }

        printf("\nPress Enter to return to the menu...");
        getchar(); // Catch any leftover newline from previous scanf
        getchar(); // Wait for the actual Enter key press

    return 0;

}
