#include "day01.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void day01_run(void) {
    const char* test_path = "../inputs/day01_test.txt";
    const char* real_path = "../inputs/day01.txt";

    run_solution("Part 1", day01_part1, test_path, real_path, 3);
    run_solution("Part 2", day01_part2, test_path, real_path, 6);
}

int64_t day01_part1(const char* input) {
    int position = 50;  // Starting position
    int zero_count = 0;

    const char* ptr = input;
    while (*ptr) {
        // Skip whitespace
        while (*ptr && isspace((unsigned char)*ptr)) ptr++;
        if (!*ptr) break;

        char direction = *ptr++;
        int distance = 0;

        // Parse number
        while (*ptr && isdigit((unsigned char)*ptr)) {
            distance = distance * 10 + (*ptr - '0');
            ptr++;
        }

        if (direction == 'L') {
            position = (position - distance) % 100;
            if (position < 0) position += 100;
        } else if (direction == 'R') {
            position = (position + distance) % 100;
        }

        if (position == 0) {
            zero_count++;
        }
    }

    return zero_count;
}

int64_t day01_part2(const char* input) {
    int position = 50;  // Starting position
    int zero_count = 0;

    const char* ptr = input;
    while (*ptr) {
        // Skip whitespace
        while (*ptr && isspace((unsigned char)*ptr)) ptr++;
        if (!*ptr) break;

        char direction = *ptr++;
        int distance = 0;

        // Parse number
        while (*ptr && isdigit((unsigned char)*ptr)) {
            distance = distance * 10 + (*ptr - '0');
            ptr++;
        }

        if (direction == 'R') {
            // Moving right: count multiples of 100 in range (position, position + distance]
            zero_count += (position + distance) / 100;
            position = (position + distance) % 100;
        } else if (direction == 'L') {
            // Moving left: count multiples of 100 in range [position - distance, position)
            int start_floor = (position - 1) < 0 ? -1 : 0;

            int temp = position - distance - 1;
            int end_floor;
            if (temp >= 0) {
                end_floor = temp / 100;
            } else {
                // Floor division for negative numbers
                end_floor = (temp - 99) / 100;
            }

            zero_count += start_floor - end_floor;

            position = (position - distance) % 100;
            if (position < 0) position += 100;
        }
    }

    return zero_count;
}
