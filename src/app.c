#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// Function to find markers in a BMP image
uint32_t find_markers(uint8_t *bmp, uint32_t *xArrayPtr, uint32_t *yArrayPtr);

// Function to read the contents of a file into memory
uint8_t* readFile(const char *file_name) {
    
    FILE *file = fopen(file_name, "r");
    // Check for file opening error
    if (file == NULL) return NULL;

    // Determine the size of the file
    fseek(file, 0, SEEK_END);
    long size = ftell(file); 
    fseek(file, 0, SEEK_SET);

    // Allocate memory for the file content
    uint8_t *data = (uint8_t *)malloc(size);

    // Read the content of the file
    if (fread(data, 1, size, file) != size) {
        free(data); 
        data = NULL; 
    }

    fclose(file);

    return data;
}

int main(int argc, char *argv[]) {
    // Check if the file name is provided in the command line arguments
    if (argc < 2) return 1;

    // Read the content of the file
    uint8_t *bmp = readFile(argv[1]);

    // Check if file reading is successful
    if (bmp == NULL) return 1;

    // Arrays to store the coordinates of markers
    uint32_t xArray[50];  
    uint32_t yArray[50];

    // Find markers in the BMP image
    uint32_t amount = find_markers(bmp, xArray, yArray);

    // Print the number of markers found
    printf("%d\n", amount);
    
    // Print the coordinates of each found marker
    for (int i = 0; i < amount; i++) {
        printf("%d: %d, %d\n", i+1, xArray[i], yArray[i]);
    }

    // Free the memory allocated for the file content
    free(bmp);

    return 0;
}
