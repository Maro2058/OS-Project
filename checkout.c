#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <string.h>
#include <sched.h>

// These variables live in the same memory space and are accessible by all threads.
long long int shared_item_id = -1; // Buffer to pass the scanner ID to the background 
float total_bill = 0.0; // Total bill of the customer
int checkout_active = 1; // Global flag to control checkout

// Synchronization Primitives
// Mutex: Prevents "Race Conditions" where both threads try to edit the bill at once.
// Condition Variable: Allows the background thread to "sleep" until signaled.
pthread_mutex_t lock; // Mutex for synchronizing access to shared data
pthread_cond_t data_ready; // Condition variable to signal data readiness

void display_live_receipt(long long int new_id, char* name, float price) {
    FILE *receipt = fopen("receipt_live.txt", "a");
    if (receipt) {
        fprintf(receipt, "Name: %s | %.2f EGP\n", name, price);
        fclose(receipt);
    }

    // Refresh the terminal UI
    system("clear"); 
    printf("========================================\n");
    printf("       SUPERMARKET LIVE RECEIPT         \n");
    printf("========================================\n");
    
    // Display current receipt
    system("cat receipt_live.txt");
    
    printf("----------------------------------------\n");
    printf(" TOTAL DUE: $%.2f\n", total_bill);
    printf("========================================\n");
}


// Thread 1: Scanner Thread (Foreground process), scans item IDs and updates total bill
void* scanner_thread(void* arg) {
    long long int id; // Item ID input by user
    char line[200]; // Buffer to read lines from inventory file
    char input_buffer[100]; // Buffer to hold the raw input line

    // reset live receipt file
    FILE *receipt = fopen("receipt_live.txt", "w"); // Open receipt file for writing
    if (receipt) fclose(receipt); // Close immediately, will append later

    // continually scan items until checkout is done
    while (checkout_active) {
        printf("\nEnter Item ID (0 to finish): "); // takes input, if 0, checkout is done
        // 1. Read the WHOLE line from the keyboard/scanner
        if (fgets(input_buffer, sizeof(input_buffer), stdin) == NULL) continue;

        // 2. Extract the long long ID from that line
        // If sscanf fails to find a number at the start, skip this input
        if (sscanf(input_buffer, "%lld", &id) != 1) {
            printf("[ERROR] Invalid input. Please scan a numeric barcode.\n");
            continue;
        }

        if (id == 0) { // if id = 0, that means user is done checking out
            pthread_mutex_lock(&lock); // Lock before changing shared variable
            checkout_active = 0; // Set flag to indicate checkout is done
            pthread_cond_signal(&data_ready); // Signals the background thread to wake up and exit its loop
            pthread_mutex_unlock(&lock); 
            break; // exit the while loop to terminate the thread
        }
        
        // Scanning algorithm
        pthread_mutex_lock(&lock); // Lock before accessing shared variable
        shared_item_id = id; // Place scanned ID into shared buffer
        int found = 0; // Flag to check if item is found
        sleep(1); // Simulate time taken to scan

        FILE *file = fopen("inventory.txt", "r"); // Open inventory file
        // Error handling for file open
        if (file == NULL) {
            perror("Failed to open inventory file");
            pthread_mutex_unlock(&lock);
            continue;
        }
        // Read inventory file line by line
        while (fgets(line, sizeof(line), file)) {
            long long int item_id; // Variables to hold parsed data
            char item_name[100]; // Assuming max name length is 99
            int item_quantity; // Quantity of the item
            float item_price; // Price of the item
            // the %["^:"] specifier reads a string until a colon is encountered, cuz some names may have spaces
            sscanf(line, "%lld:%[^:]:%d:%f", &item_id, item_name, &item_quantity, &item_price);
            if (item_id == shared_item_id) { // Match found
                if (item_quantity <= 0) { // Check if item is out of stock
                    printf("Item %s is out of stock!\n", item_name); // Notify user
                    shared_item_id = -1; // Reset shared buffer
                    found = 1; // Set found flag
                    break; // Exit the loop early
                }
                total_bill += item_price; // Update total bill
                display_live_receipt(item_id, item_name, item_price); // Update live receipt display
                found = 1; // Set found flag
                break; // Exit the loop early
            }

        } 
        
        fclose(file); // Close the file

        if (!found) {
            printf("Item ID %lld not found in inventory.\n", shared_item_id); // Notify user that item not found
            shared_item_id = -1; // Reset shared buffer
            pthread_mutex_unlock(&lock);
            continue;
        }
        else {


            pthread_cond_signal(&data_ready); // Signal manager thread that data is ready
            pthread_mutex_unlock(&lock); // CRITICAL: Unlock before breaking
        }

    }



    return NULL;
}


// Thread 2: Update inventory
// This thread performs disk I/O concurrently with the user scanning.
void* update_inventory_thread(void* arg) {
    while (1) {
        pthread_mutex_lock(&lock);

        // Wait until there's data to process
        while (shared_item_id == -1 && checkout_active) {
            pthread_cond_wait(&data_ready, &lock);
        }
        // Exit condition: if checkout is done and no more items to process
        if (!checkout_active && shared_item_id == -1) {
            pthread_mutex_unlock(&lock);
            break;
        }

        // Update inventory algorithm
        FILE *file = fopen("inventory.txt", "r"); // Open inventory file for reading
        FILE *temp_file = fopen("temp_inventory.txt", "w"); // Temporary file for writing updates
        if (file == NULL || temp_file == NULL) { // Error handling for file open
            perror("Failed to open inventory file");
            pthread_mutex_unlock(&lock);
            continue;
        }
        // Read inventory file line by line
        char line[200]; // Buffer to read lines
        while (fgets(line, sizeof(line), file)) { // Read each line
            long long int item_id; // Variables to hold parsed data
            char item_name[100]; // Assuming max name length is 99
            int item_quantity;// Quantity of the item
            float item_price; // Price of the item
            // the %["^:"] specifier reads a string until a colon is encountered, cuz some names may have spaces
            sscanf(line, "%lld:%[^:]:%d:%f", &item_id, item_name, &item_quantity, &item_price); // Parse the line
            // If this is the scanned item, decrement its quantity
            if (item_id == shared_item_id) {
                if (item_quantity > 0) {
                    item_quantity--; // Decrement quantity
                } else {
                    printf("Item %s is out of stock!\n", item_name);
                }
            }
            fprintf(temp_file, "%lld:%s:%d:%.2f\n", item_id, item_name, item_quantity, item_price); // Write updated line to temp file
        }
        // End of file reading loop
        fclose(file);
        fclose(temp_file);

        // Replace original inventory file with updated temp file
        remove("inventory.txt");
        rename("temp_inventory.txt", "inventory.txt");

        // Reset buffer
        shared_item_id = -1; 
        pthread_mutex_unlock(&lock);

    }
    return NULL;
}


int main() {
    pthread_t scanner_thread_id, update_inventory_thread_id; // Thread IDs
    pthread_attr_t attr; // Thread attributes
    struct sched_param param; // Scheduling parameters
    // sched_param structure holds the scheduling parameters for a thread, pre-defined


    // Initialize mutex and condition variable
    //pthread_mutex_init takes two arguments: a pointer to the mutex and optional attributes (NULL for default)
    pthread_mutex_init(&lock, NULL);
    //pthread_cond_init takes two arguments: a pointer to the condition variable and optional attributes (NULL for default)
    pthread_cond_init(&data_ready, NULL);

    // Set thread attributes
    pthread_attr_init(&attr); // Initialize thread attributes
    pthread_attr_setschedpolicy(&attr, SCHED_RR); // Set scheduling policy to Round Robin which is fair for time-sharing
    param.sched_priority = 10; // Set thread priority (1-99 for real-time policies)
    pthread_attr_setschedparam(&attr, &param); // Apply scheduling parameters to attributes 


    // Create threads
    // 1st arg: pointer to thread ID, 2nd arg: thread attributes (NULL for default),
    // 3rd arg: function to run, 4th arg: argument to the function (NULL here)
    pthread_create(&scanner_thread_id, &attr, scanner_thread, NULL); // Create scanner thread
    pthread_create(&update_inventory_thread_id, &attr, update_inventory_thread, NULL); // Create inventory update thread

    // Wait for threads to finish
    // 1st arg: thread ID, 2nd arg: pointer to return value (NULL if not needed)
    pthread_join(scanner_thread_id, NULL); // Wait for scanner thread to finish
    pthread_join(update_inventory_thread_id, NULL); // Wait for inventory update thread to finish

    // Clean up
    pthread_attr_destroy(&attr); // Destroy thread attributes
    pthread_mutex_destroy(&lock); // Destroy mutex
    pthread_cond_destroy(&data_ready); // Destroy condition variable
    
    // Final Receipt view
    
    printf("\n========================================\n");
    system("clear"); 
    printf("========================================\n");
    printf("       SUPERMARKET RECEIPT         \n");
    printf("========================================\n");
    
    // Display current receipt
    system("cat receipt_live.txt");
    
    printf("----------------------------------------\n");
    printf(" TOTAL DUE: %.2f EGP\n", total_bill);
    printf("========================================\n");

    // Press anything to continue
    printf("\nPress Enter to return to the menu...");
    getchar(); // Catch any leftover newline from previous scanf
    getchar(); // Wait for the actual Enter key press
    
    return 0;

}