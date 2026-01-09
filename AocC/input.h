#ifndef INPUT_H
#define INPUT_H

#include <stdbool.h>

// Read entire file contents into a dynamically allocated string
// Caller is responsible for freeing the returned pointer
char* read_input(const char* filepath);

// Check if a file exists
bool file_exists(const char* filepath);

#endif // INPUT_H
