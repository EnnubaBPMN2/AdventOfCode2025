#include "day07.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void day07_run(void) {
    const char* test_path = "../inputs/day07_test.txt";
    const char* real_path = "../inputs/day07.txt";

    run_solution("Part 1", day07_part1, test_path, real_path, 21);
    run_solution("Part 2", day07_part2, test_path, real_path, 40);
}

int64_t day07_part1(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    // Parse lines
    char* lines[1000];
    int height = 0;

    char* line = strtok(data, "\r\n");
    while (line && height < 1000) {
        lines[height++] = line;
        line = strtok(NULL, "\r\n");
    }

    if (height == 0) {
        free(data);
        return 0;
    }

    int width = (int)strlen(lines[0]);

    // Find starting position 'S'
    int start_row = -1, start_col = -1;
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < (int)strlen(lines[row]); col++) {
            if (lines[row][col] == 'S') {
                start_row = row;
                start_col = col;
                break;
            }
        }
        if (start_row != -1) break;
    }

    if (start_row == -1) {
        free(data);
        return 0;
    }

    // Track beams using a set (simple array for small widths)
    bool current_beams[1000] = {false};
    current_beams[start_col] = true;

    int64_t split_count = 0;

    for (int row = start_row + 1; row < height; row++) {
        bool next_beams[1000] = {false};
        int line_len = (int)strlen(lines[row]);

        for (int col = 0; col < width; col++) {
            if (!current_beams[col]) continue;
            if (col >= line_len) continue;

            char cell = lines[row][col];

            if (cell == '^') {
                split_count++;
                if (col - 1 >= 0) next_beams[col - 1] = true;
                if (col + 1 < width) next_beams[col + 1] = true;
            } else {
                next_beams[col] = true;
            }
        }

        memcpy(current_beams, next_beams, sizeof(current_beams));

        // Check if any beams left
        bool has_beams = false;
        for (int i = 0; i < width; i++) {
            if (current_beams[i]) {
                has_beams = true;
                break;
            }
        }
        if (!has_beams) break;
    }

    free(data);
    return split_count;
}

int64_t day07_part2(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    // Parse lines
    char* lines[1000];
    int height = 0;

    char* line = strtok(data, "\r\n");
    while (line && height < 1000) {
        lines[height++] = line;
        line = strtok(NULL, "\r\n");
    }

    if (height == 0) {
        free(data);
        return 0;
    }

    int width = (int)strlen(lines[0]);

    // Find starting position 'S'
    int start_row = -1, start_col = -1;
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < (int)strlen(lines[row]); col++) {
            if (lines[row][col] == 'S') {
                start_row = row;
                start_col = col;
                break;
            }
        }
        if (start_row != -1) break;
    }

    if (start_row == -1) {
        free(data);
        return 0;
    }

    // Track path counts per column
    int64_t current_paths[1000] = {0};
    current_paths[start_col] = 1;

    for (int row = start_row + 1; row < height; row++) {
        int64_t next_paths[1000] = {0};
        int line_len = (int)strlen(lines[row]);

        for (int col = 0; col < width; col++) {
            if (current_paths[col] == 0) continue;
            if (col >= line_len) continue;

            char cell = lines[row][col];

            if (cell == '^') {
                if (col - 1 >= 0) next_paths[col - 1] += current_paths[col];
                if (col + 1 < width) next_paths[col + 1] += current_paths[col];
            } else {
                next_paths[col] += current_paths[col];
            }
        }

        memcpy(current_paths, next_paths, sizeof(current_paths));

        // Check if any paths left
        bool has_paths = false;
        for (int i = 0; i < width; i++) {
            if (current_paths[i] > 0) {
                has_paths = true;
                break;
            }
        }
        if (!has_paths) break;
    }

    // Sum all paths at bottom
    int64_t total = 0;
    for (int i = 0; i < width; i++) {
        total += current_paths[i];
    }

    free(data);
    return total;
}
