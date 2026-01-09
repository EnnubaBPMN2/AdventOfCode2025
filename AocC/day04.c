#include "day04.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void day04_run(void) {
    const char* test_path = "../inputs/day04_test.txt";
    const char* real_path = "../inputs/day04.txt";

    run_solution("Part 1", day04_part1, test_path, real_path, 13);
    run_solution("Part 2", day04_part2, test_path, real_path, 43);
}

// Directions: N, NE, E, SE, S, SW, W, NW
static const int dr[] = {-1, -1, 0, 1, 1, 1, 0, -1};
static const int dc[] = {0, 1, 1, 1, 0, -1, -1, -1};

int64_t day04_part1(const char* input) {
    // Parse lines
    char* data = strdup(input);
    if (!data) return 0;

    char* lines[1000];
    int rows = 0;

    char* line = strtok(data, "\r\n");
    while (line && rows < 1000) {
        lines[rows++] = line;
        line = strtok(NULL, "\r\n");
    }

    if (rows == 0) {
        free(data);
        return 0;
    }

    int cols = (int)strlen(lines[0]);
    int64_t accessible = 0;

    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols && c < (int)strlen(lines[r]); c++) {
            if (lines[r][c] == '@') {
                int neighbors = 0;
                for (int i = 0; i < 8; i++) {
                    int nr = r + dr[i];
                    int nc = c + dc[i];

                    if (nr >= 0 && nr < rows && nc >= 0 && nc < (int)strlen(lines[nr])) {
                        if (lines[nr][nc] == '@') {
                            neighbors++;
                        }
                    }
                }

                if (neighbors < 4) {
                    accessible++;
                }
            }
        }
    }

    free(data);
    return accessible;
}

int64_t day04_part2(const char* input) {
    // Parse lines into mutable grid
    char* data = strdup(input);
    if (!data) return 0;

    char* lines[1000];
    int rows = 0;

    char* line = strtok(data, "\r\n");
    while (line && rows < 1000) {
        lines[rows++] = line;
        line = strtok(NULL, "\r\n");
    }

    if (rows == 0) {
        free(data);
        return 0;
    }

    int64_t total_removed = 0;

    // Create mutable grid
    char* grid[1000];
    for (int i = 0; i < rows; i++) {
        grid[i] = strdup(lines[i]);
    }

    while (1) {
        // Find cells to remove
        int to_remove_r[10000];
        int to_remove_c[10000];
        int remove_count = 0;

        for (int r = 0; r < rows; r++) {
            int line_len = (int)strlen(grid[r]);
            for (int c = 0; c < line_len; c++) {
                if (grid[r][c] == '@') {
                    int neighbors = 0;
                    for (int i = 0; i < 8; i++) {
                        int nr = r + dr[i];
                        int nc = c + dc[i];

                        if (nr >= 0 && nr < rows && nc >= 0 && nc < (int)strlen(grid[nr])) {
                            if (grid[nr][nc] == '@') {
                                neighbors++;
                            }
                        }
                    }

                    if (neighbors < 4) {
                        to_remove_r[remove_count] = r;
                        to_remove_c[remove_count] = c;
                        remove_count++;
                    }
                }
            }
        }

        if (remove_count == 0) break;

        total_removed += remove_count;

        for (int i = 0; i < remove_count; i++) {
            grid[to_remove_r[i]][to_remove_c[i]] = '.';
        }
    }

    // Free grid
    for (int i = 0; i < rows; i++) {
        free(grid[i]);
    }
    free(data);

    return total_removed;
}
