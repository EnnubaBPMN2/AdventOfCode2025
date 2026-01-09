#include "runner.h"
#include "input.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <inttypes.h>

// ANSI color codes
#define COLOR_RESET   "\033[0m"
#define COLOR_CYAN    "\033[36m"
#define COLOR_GREEN   "\033[32m"
#define COLOR_RED     "\033[31m"
#define COLOR_YELLOW  "\033[33m"

void run_solution(
    const char* part_name,
    SolverFunc solver,
    const char* test_path,
    const char* real_path,
    int64_t expected_test_result
) {
    printf("\n");
    printf(COLOR_YELLOW "=== %s ===" COLOR_RESET "\n", part_name);

    // Run test if expected result is provided and test file exists
    if (expected_test_result != 0 && file_exists(test_path)) {
        char* test_input = read_input(test_path);
        if (test_input) {
            printf(COLOR_CYAN "Running %s (Test)... " COLOR_RESET, part_name);
            fflush(stdout);

            clock_t start = clock();
            int64_t result = solver(test_input);
            clock_t end = clock();
            double duration = (double)(end - start) / CLOCKS_PER_SEC;

            if (result == expected_test_result) {
                printf(COLOR_GREEN "✓ PASSED (Result: %" PRId64 ") [%.3fs]" COLOR_RESET "\n",
                       result, duration);
            } else {
                printf(COLOR_RED "✗ FAILED (Expected: %" PRId64 ", Got: %" PRId64 ") [%.3fs]" COLOR_RESET "\n",
                       expected_test_result, result, duration);
            }

            free(test_input);
        }
    }

    // Run with real input
    if (file_exists(real_path)) {
        char* real_input = read_input(real_path);
        if (real_input) {
            // Check if input is empty or placeholder
            if (strlen(real_input) == 0 || real_input[0] == '#') {
                printf(COLOR_YELLOW "⚠ Real input file is empty or contains placeholder text" COLOR_RESET "\n");
                free(real_input);
                return;
            }

            printf(COLOR_CYAN "Running %s (Real Input)... " COLOR_RESET, part_name);
            fflush(stdout);

            clock_t start = clock();
            int64_t result = solver(real_input);
            clock_t end = clock();
            double duration = (double)(end - start) / CLOCKS_PER_SEC;

            printf(COLOR_GREEN "Result: %" PRId64 " [%.3fs]" COLOR_RESET "\n", result, duration);

            free(real_input);
        }
    } else {
        printf(COLOR_YELLOW "⚠ Real input file not found: %s" COLOR_RESET "\n", real_path);
    }
}
