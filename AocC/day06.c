#include "day06.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>

void day06_run(void) {
    const char* test_path = "../inputs/day06_test.txt";
    const char* real_path = "../inputs/day06.txt";

    run_solution("Part 1", day06_part1, test_path, real_path, 4277556);
    run_solution("Part 2", day06_part2, test_path, real_path, 3263827);
}

typedef struct {
    int64_t numbers[100];
    int number_count;
    char op;
} Problem;

static Problem parse_problem(char** grid, int height, int start_col, int end_col) {
    Problem p;
    p.number_count = 0;
    p.op = ' ';

    // Numbers are in all rows except the last
    for (int row = 0; row < height - 1; row++) {
        // Find first and last non-space characters in the range
        int start = -1, end = -1;
        for (int col = start_col; col <= end_col; col++) {
            char c = grid[row][col];
            if (c != ' ') {
                if (start == -1) start = col;
                end = col;
            }
        }

        if (start != -1) {
            // Extract number
            char buf[32];
            int len = 0;
            for (int col = start; col <= end && len < 31; col++) {
                buf[len++] = grid[row][col];
            }
            buf[len] = '\0';

            int64_t num;
            if (sscanf(buf, "%lld", (long long*)&num) == 1) {
                p.numbers[p.number_count++] = num;
            }
        }
    }

    // Operator is in the last row
    for (int col = start_col; col <= end_col; col++) {
        char c = grid[height - 1][col];
        if (c == '+' || c == '*') {
            p.op = c;
            break;
        }
    }

    return p;
}

static Problem parse_problem_rtl(char** grid, int height, int start_col, int end_col) {
    Problem p;
    p.number_count = 0;
    p.op = ' ';

    // Read each column from right to left
    for (int col = end_col; col >= start_col; col--) {
        // Build number from digits in this column (top to bottom, excluding operator row)
        int64_t num = 0;
        bool has_digits = false;

        for (int row = 0; row < height - 1; row++) {
            char c = grid[row][col];
            if (c != ' ' && isdigit((unsigned char)c)) {
                num = num * 10 + (c - '0');
                has_digits = true;
            }
        }

        if (has_digits) {
            p.numbers[p.number_count++] = num;
        }
    }

    // Operator is in the last row
    for (int col = start_col; col <= end_col; col++) {
        char c = grid[height - 1][col];
        if (c == '+' || c == '*') {
            p.op = c;
            break;
        }
    }

    return p;
}

int64_t day06_part1(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    // Parse lines - use dynamic allocation for large inputs
    char** lines = (char**)malloc(1000 * sizeof(char*));
    int height = 0;

    char* line = strtok(data, "\r\n");
    while (line && height < 1000) {
        lines[height++] = line;
        line = strtok(NULL, "\r\n");
    }

    if (height == 0) {
        free(lines);
        free(data);
        return 0;
    }

    // Find max width
    int width = 0;
    for (int i = 0; i < height; i++) {
        int len = (int)strlen(lines[i]);
        if (len > width) width = len;
    }

    // Pad lines to same width - dynamic allocation
    char** grid = (char**)malloc(height * sizeof(char*));
    for (int i = 0; i < height; i++) {
        grid[i] = (char*)malloc(width + 1);
        int len = (int)strlen(lines[i]);
        memcpy(grid[i], lines[i], len);
        for (int j = len; j < width; j++) {
            grid[i][j] = ' ';
        }
        grid[i][width] = '\0';
    }

    // Find problem blocks - dynamic allocation
    Problem* problems = (Problem*)malloc(10000 * sizeof(Problem));
    int problem_count = 0;
    int start_col = -1;

    for (int col = 0; col < width; col++) {
        bool is_empty = true;
        for (int row = 0; row < height; row++) {
            if (grid[row][col] != ' ') {
                is_empty = false;
                break;
            }
        }

        if (!is_empty) {
            if (start_col == -1) start_col = col;
        } else {
            if (start_col != -1) {
                problems[problem_count++] = parse_problem(grid, height, start_col, col - 1);
                start_col = -1;
            }
        }
    }

    if (start_col != -1) {
        problems[problem_count++] = parse_problem(grid, height, start_col, width - 1);
    }

    // Calculate total
    int64_t total = 0;
    for (int i = 0; i < problem_count; i++) {
        Problem* p = &problems[i];
        if (p->number_count == 0) continue;

        int64_t result = p->numbers[0];
        for (int j = 1; j < p->number_count; j++) {
            if (p->op == '+') result += p->numbers[j];
            else if (p->op == '*') result *= p->numbers[j];
        }
        total += result;
    }

    // Cleanup
    for (int i = 0; i < height; i++) {
        free(grid[i]);
    }
    free(grid);
    free(problems);
    free(lines);
    free(data);

    return total;
}

int64_t day06_part2(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    // Parse lines - use dynamic allocation for large inputs
    char** lines = (char**)malloc(1000 * sizeof(char*));
    int height = 0;

    char* line = strtok(data, "\r\n");
    while (line && height < 1000) {
        lines[height++] = line;
        line = strtok(NULL, "\r\n");
    }

    if (height == 0) {
        free(lines);
        free(data);
        return 0;
    }

    // Find max width
    int width = 0;
    for (int i = 0; i < height; i++) {
        int len = (int)strlen(lines[i]);
        if (len > width) width = len;
    }

    // Pad lines to same width - dynamic allocation
    char** grid = (char**)malloc(height * sizeof(char*));
    for (int i = 0; i < height; i++) {
        grid[i] = (char*)malloc(width + 1);
        int len = (int)strlen(lines[i]);
        memcpy(grid[i], lines[i], len);
        for (int j = len; j < width; j++) {
            grid[i][j] = ' ';
        }
        grid[i][width] = '\0';
    }

    // Find problem blocks - dynamic allocation
    Problem* problems = (Problem*)malloc(10000 * sizeof(Problem));
    int problem_count = 0;
    int start_col = -1;

    for (int col = 0; col < width; col++) {
        bool is_empty = true;
        for (int row = 0; row < height; row++) {
            if (grid[row][col] != ' ') {
                is_empty = false;
                break;
            }
        }

        if (!is_empty) {
            if (start_col == -1) start_col = col;
        } else {
            if (start_col != -1) {
                problems[problem_count++] = parse_problem_rtl(grid, height, start_col, col - 1);
                start_col = -1;
            }
        }
    }

    if (start_col != -1) {
        problems[problem_count++] = parse_problem_rtl(grid, height, start_col, width - 1);
    }

    // Calculate total
    int64_t total = 0;
    for (int i = 0; i < problem_count; i++) {
        Problem* p = &problems[i];
        if (p->number_count == 0) continue;

        int64_t result = p->numbers[0];
        for (int j = 1; j < p->number_count; j++) {
            if (p->op == '+') result += p->numbers[j];
            else if (p->op == '*') result *= p->numbers[j];
        }
        total += result;
    }

    // Cleanup
    for (int i = 0; i < height; i++) {
        free(grid[i]);
    }
    free(grid);
    free(problems);
    free(lines);
    free(data);

    return total;
}
