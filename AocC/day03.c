#include "day03.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void day03_run(void) {
    const char* test_path = "../inputs/day03_test.txt";
    const char* real_path = "../inputs/day03.txt";

    run_solution("Part 1", day03_part1, test_path, real_path, 357);
    run_solution("Part 2", day03_part2, test_path, real_path, 3121910778619LL);
}

int64_t day03_part1(const char* input) {
    int64_t total = 0;
    const char* line_start = input;

    while (*line_start) {
        // Find end of line
        const char* line_end = line_start;
        while (*line_end && *line_end != '\n' && *line_end != '\r') {
            line_end++;
        }

        int len = (int)(line_end - line_start);
        if (len > 0) {
            int max_joltage = -1;

            for (int i = 0; i < len; i++) {
                if (!isdigit((unsigned char)line_start[i])) continue;
                int digit_i = line_start[i] - '0';

                for (int j = i + 1; j < len; j++) {
                    if (!isdigit((unsigned char)line_start[j])) continue;
                    int digit_j = line_start[j] - '0';
                    int joltage = digit_i * 10 + digit_j;
                    if (joltage > max_joltage) {
                        max_joltage = joltage;
                    }
                }
            }

            if (max_joltage != -1) {
                total += max_joltage;
            }
        }

        // Move to next line
        while (*line_end == '\n' || *line_end == '\r') {
            line_end++;
        }
        line_start = line_end;
    }

    return total;
}

int64_t day03_part2(const char* input) {
    int64_t total = 0;
    const int k = 12;  // Target length
    const char* line_start = input;

    while (*line_start) {
        // Find end of line
        const char* line_end = line_start;
        while (*line_end && *line_end != '\n' && *line_end != '\r') {
            line_end++;
        }

        int len = (int)(line_end - line_start);
        if (len > 0) {
            // Stack-based monotonic decreasing algorithm
            int stack[20];  // Max k digits
            int stack_size = 0;

            for (int i = 0; i < len; i++) {
                if (!isdigit((unsigned char)line_start[i])) continue;

                int digit = line_start[i] - '0';
                int remaining = 0;

                // Count remaining digits
                for (int j = i + 1; j < len; j++) {
                    if (isdigit((unsigned char)line_start[j])) {
                        remaining++;
                    }
                }

                while (stack_size > 0 && digit > stack[stack_size - 1] &&
                       stack_size + remaining >= k) {
                    stack_size--;
                }

                if (stack_size < k) {
                    stack[stack_size++] = digit;
                }
            }

            // Construct number from stack
            int64_t max_joltage = 0;
            for (int i = 0; i < stack_size; i++) {
                max_joltage = max_joltage * 10 + stack[i];
            }

            total += max_joltage;
        }

        // Move to next line
        while (*line_end == '\n' || *line_end == '\r') {
            line_end++;
        }
        line_start = line_end;
    }

    return total;
}
