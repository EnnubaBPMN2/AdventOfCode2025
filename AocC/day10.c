#include "day10.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <math.h>

void day10_run(void) {
    const char* test_path = "../inputs/day10_test.txt";
    const char* real_path = "../inputs/day10.txt";

    run_solution("Part 1", day10_part1, test_path, real_path, 7);
    run_solution("Part 2", day10_part2, test_path, real_path, 33);
}

typedef struct {
    bool target[100];
    bool buttons[100][100];
    int num_lights;
    int num_buttons;
} MachinePart1;

typedef struct {
    int64_t targets[100];
    int buttons[100][100];
    int num_counters;
    int num_buttons;
} MachinePart2;

static MachinePart1 parse_machine_part1(const char* line) {
    MachinePart1 m = {0};

    // Find indicator [.##.]
    const char* bracket_start = strchr(line, '[');
    const char* bracket_end = strchr(line, ']');

    if (!bracket_start || !bracket_end) return m;

    int indicator_len = (int)(bracket_end - bracket_start - 1);
    m.num_lights = indicator_len;

    for (int i = 0; i < indicator_len; i++) {
        m.target[i] = (bracket_start[1 + i] == '#');
    }

    // Parse buttons (0,1,2) - find all (...) groups
    const char* ptr = bracket_end + 1;
    while (*ptr) {
        // Find next (
        while (*ptr && *ptr != '(' && *ptr != '{') ptr++;
        if (*ptr != '(') break;

        const char* open = ptr;
        const char* close = strchr(open, ')');
        if (!close) break;

        // Parse button indices
        char buf[256];
        int len = (int)(close - open - 1);
        if (len >= 256) len = 255;
        strncpy(buf, open + 1, len);
        buf[len] = '\0';

        // Parse comma-separated numbers
        char* sep = buf;
        while (*sep) {
            char* next = strchr(sep, ',');
            if (next) *next = '\0';
            int idx = atoi(sep);
            if (idx >= 0 && idx < m.num_lights) {
                m.buttons[m.num_buttons][idx] = true;
            }
            if (!next) break;
            sep = next + 1;
        }
        m.num_buttons++;

        ptr = close + 1;
    }

    return m;
}

static int solve_gf2(MachinePart1* m) {
    int rows = m->num_lights;
    int cols = m->num_buttons;

    if (cols == 0) return 0;

    // Build augmented matrix [A | b]
    bool matrix[100][101];
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            matrix[r][c] = m->buttons[c][r];
        }
        matrix[r][cols] = m->target[r];
    }

    // Gaussian elimination in GF(2)
    int pivot[100];
    for (int i = 0; i < rows; i++) pivot[i] = -1;

    int row = 0, col = 0;
    while (row < rows && col < cols) {
        int pivot_row = -1;
        for (int r = row; r < rows; r++) {
            if (matrix[r][col]) {
                pivot_row = r;
                break;
            }
        }

        if (pivot_row == -1) {
            col++;
            continue;
        }

        // Swap rows
        if (pivot_row != row) {
            for (int c = 0; c <= cols; c++) {
                bool tmp = matrix[row][c];
                matrix[row][c] = matrix[pivot_row][c];
                matrix[pivot_row][c] = tmp;
            }
        }

        pivot[row] = col;

        // Eliminate
        for (int r = 0; r < rows; r++) {
            if (r != row && matrix[r][col]) {
                for (int c = 0; c <= cols; c++) {
                    matrix[r][c] ^= matrix[row][c];
                }
            }
        }

        row++;
        col++;
    }

    // Check for inconsistency
    for (int r = 0; r < rows; r++) {
        bool all_zero = true;
        for (int c = 0; c < cols; c++) {
            if (matrix[r][c]) {
                all_zero = false;
                break;
            }
        }
        if (all_zero && matrix[r][cols]) {
            return 0;  // No solution
        }
    }

    // Find free variables
    int free_vars[100];
    int num_free = 0;
    bool is_pivot[100] = {false};
    for (int r = 0; r < rows; r++) {
        if (pivot[r] != -1) is_pivot[pivot[r]] = true;
    }
    for (int c = 0; c < cols; c++) {
        if (!is_pivot[c]) free_vars[num_free++] = c;
    }

    // Enumerate solutions
    int min_presses = 1000000;
    int max_comb = (num_free > 15) ? (1 << 15) : (1 << num_free);

    for (int mask = 0; mask < max_comb; mask++) {
        bool sol[100] = {false};

        for (int i = 0; i < num_free && i < 15; i++) {
            sol[free_vars[i]] = ((mask >> i) & 1);
        }

        for (int r = rows - 1; r >= 0; r--) {
            if (pivot[r] == -1) continue;
            bool val = matrix[r][cols];
            for (int c = pivot[r] + 1; c < cols; c++) {
                if (matrix[r][c] && sol[c]) val ^= true;
            }
            sol[pivot[r]] = val;
        }

        int count = 0;
        for (int i = 0; i < cols; i++) {
            if (sol[i]) count++;
        }
        if (count < min_presses) min_presses = count;
    }

    return (min_presses == 1000000) ? 0 : min_presses;
}

int64_t day10_part1(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    int64_t total = 0;

    // Parse lines without using strtok (avoid issues)
    char* ptr = data;
    while (*ptr) {
        char* line_start = ptr;
        while (*ptr && *ptr != '\n' && *ptr != '\r') ptr++;
        char saved = *ptr;
        if (*ptr) *ptr++ = '\0';
        while (*ptr == '\n' || *ptr == '\r') ptr++;

        if (strlen(line_start) > 0) {
            MachinePart1 m = parse_machine_part1(line_start);
            total += solve_gf2(&m);
        }

        if (saved == '\0') break;
    }

    free(data);
    return total;
}

static MachinePart2 parse_machine_part2(const char* line) {
    MachinePart2 m = {0};

    // Find joltage requirements {3,5,4,7}
    const char* brace_start = strchr(line, '{');
    const char* brace_end = strchr(line, '}');

    if (!brace_start || !brace_end) return m;

    // Parse targets
    char buf[256];
    int len = (int)(brace_end - brace_start - 1);
    if (len >= 256) len = 255;
    strncpy(buf, brace_start + 1, len);
    buf[len] = '\0';

    // Parse comma-separated numbers for targets
    char* sep = buf;
    while (*sep && m.num_counters < 100) {
        char* next = strchr(sep, ',');
        if (next) *next = '\0';
        m.targets[m.num_counters++] = atoll(sep);
        if (!next) break;
        sep = next + 1;
    }

    // Find indicator end
    const char* bracket_end = strchr(line, ']');
    if (!bracket_end) return m;

    // Parse buttons between ] and {
    const char* ptr = bracket_end + 1;
    while (ptr < brace_start) {
        // Find next (
        while (ptr < brace_start && *ptr != '(') ptr++;
        if (ptr >= brace_start || *ptr != '(') break;

        const char* open = ptr;
        const char* close = strchr(open, ')');
        if (!close || close > brace_start) break;

        // Parse button indices
        char btn_buf[256];
        int btn_len = (int)(close - open - 1);
        if (btn_len >= 256) btn_len = 255;
        strncpy(btn_buf, open + 1, btn_len);
        btn_buf[btn_len] = '\0';

        char* btn_sep = btn_buf;
        while (*btn_sep) {
            char* btn_next = strchr(btn_sep, ',');
            if (btn_next) *btn_next = '\0';
            int idx = atoi(btn_sep);
            if (idx >= 0 && idx < m.num_counters) {
                m.buttons[m.num_buttons][idx] = 1;
            }
            if (!btn_next) break;
            btn_sep = btn_next + 1;
        }
        m.num_buttons++;

        ptr = close + 1;
    }

    return m;
}

static int64_t solve_ilp(MachinePart2* m) {
    int rows = m->num_counters;
    int cols = m->num_buttons;

    if (cols == 0) return 0;

    // Build augmented matrix
    double matrix[100][101];
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            matrix[r][c] = m->buttons[c][r];
        }
        matrix[r][cols] = (double)m->targets[r];
    }

    // Gaussian elimination
    int pivot[100];
    for (int i = 0; i < rows; i++) pivot[i] = -1;

    int row = 0, col = 0;
    while (row < rows && col < cols) {
        int pivot_row = -1;
        for (int r = row; r < rows; r++) {
            if (fabs(matrix[r][col]) > 1e-9) {
                pivot_row = r;
                break;
            }
        }

        if (pivot_row == -1) {
            col++;
            continue;
        }

        // Swap rows
        if (pivot_row != row) {
            for (int c = 0; c <= cols; c++) {
                double tmp = matrix[row][c];
                matrix[row][c] = matrix[pivot_row][c];
                matrix[pivot_row][c] = tmp;
            }
        }

        pivot[row] = col;

        // Scale
        double piv = matrix[row][col];
        for (int c = 0; c <= cols; c++) {
            matrix[row][c] /= piv;
        }

        // Eliminate
        for (int r = 0; r < rows; r++) {
            if (r != row && fabs(matrix[r][col]) > 1e-9) {
                double factor = matrix[r][col];
                for (int c = 0; c <= cols; c++) {
                    matrix[r][c] -= factor * matrix[row][c];
                }
            }
        }

        row++;
        col++;
    }

    // Find free variables
    int free_vars[100];
    int num_free = 0;
    bool is_pivot[100] = {false};
    for (int r = 0; r < rows; r++) {
        if (pivot[r] != -1) is_pivot[pivot[r]] = true;
    }
    for (int c = 0; c < cols; c++) {
        if (!is_pivot[c]) free_vars[num_free++] = c;
    }

    // Find max target for search bound
    int64_t max_target = 0;
    for (int i = 0; i < m->num_counters; i++) {
        if (m->targets[i] > max_target) max_target = m->targets[i];
    }

    int64_t min_presses = INT64_MAX;

    // No free variables - unique solution
    if (num_free == 0) {
        int64_t sum = 0;
        bool valid = true;
        for (int r = 0; r < rows; r++) {
            if (pivot[r] == -1) {
                if (fabs(matrix[r][cols]) > 1e-9) {
                    valid = false;
                    break;
                }
                continue;
            }
            double val = matrix[r][cols];
            if (val < -1e-9 || fabs(val - round(val)) > 1e-9) {
                valid = false;
                break;
            }
            int64_t v = (int64_t)round(val);
            if (v < 0) {
                valid = false;
                break;
            }
            sum += v;
        }
        return valid ? sum : 0;
    }

    // Simple brute force for small free variable count
    int bound = (int)(max_target + 1);
    if (bound > 50) bound = 50;

    if (num_free == 1) {
        for (int v0 = 0; v0 <= bound; v0++) {
            int64_t sol[100] = {0};
            sol[free_vars[0]] = v0;
            int64_t sum = v0;
            bool valid = true;

            for (int r = rows - 1; r >= 0; r--) {
                if (pivot[r] == -1) continue;
                double val = matrix[r][cols];
                for (int c = pivot[r] + 1; c < cols; c++) {
                    if (fabs(matrix[r][c]) > 1e-9) {
                        val -= matrix[r][c] * sol[c];
                    }
                }
                if (val < -1e-9 || fabs(val - round(val)) > 1e-9) {
                    valid = false;
                    break;
                }
                int64_t v = (int64_t)round(val);
                if (v < 0) {
                    valid = false;
                    break;
                }
                sol[pivot[r]] = v;
                sum += v;
            }

            if (valid && sum < min_presses) min_presses = sum;
        }
    } else if (num_free == 2) {
        for (int v0 = 0; v0 <= bound; v0++) {
            for (int v1 = 0; v1 <= bound; v1++) {
                if (v0 + v1 >= min_presses) continue;
                int64_t sol[100] = {0};
                sol[free_vars[0]] = v0;
                sol[free_vars[1]] = v1;
                int64_t sum = v0 + v1;
                bool valid = true;

                for (int r = rows - 1; r >= 0; r--) {
                    if (pivot[r] == -1) continue;
                    double val = matrix[r][cols];
                    for (int c = pivot[r] + 1; c < cols; c++) {
                        if (fabs(matrix[r][c]) > 1e-9) {
                            val -= matrix[r][c] * sol[c];
                        }
                    }
                    if (val < -1e-9 || fabs(val - round(val)) > 1e-9) {
                        valid = false;
                        break;
                    }
                    int64_t v = (int64_t)round(val);
                    if (v < 0) {
                        valid = false;
                        break;
                    }
                    sol[pivot[r]] = v;
                    sum += v;
                }

                if (valid && sum < min_presses) min_presses = sum;
            }
        }
    } else {
        // Default: just use zero for free variables
        int64_t sol[100] = {0};
        int64_t sum = 0;
        bool valid = true;

        for (int r = rows - 1; r >= 0; r--) {
            if (pivot[r] == -1) continue;
            double val = matrix[r][cols];
            if (val < -1e-9 || fabs(val - round(val)) > 1e-9) {
                valid = false;
                break;
            }
            int64_t v = (int64_t)round(val);
            if (v < 0) {
                valid = false;
                break;
            }
            sol[pivot[r]] = v;
            sum += v;
        }

        if (valid && sum < min_presses) min_presses = sum;
    }

    return (min_presses == INT64_MAX) ? 0 : min_presses;
}

int64_t day10_part2(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    int64_t total = 0;

    // Parse lines without using strtok
    char* ptr = data;
    while (*ptr) {
        char* line_start = ptr;
        while (*ptr && *ptr != '\n' && *ptr != '\r') ptr++;
        char saved = *ptr;
        if (*ptr) *ptr++ = '\0';
        while (*ptr == '\n' || *ptr == '\r') ptr++;

        if (strlen(line_start) > 0) {
            MachinePart2 m = parse_machine_part2(line_start);
            total += solve_ilp(&m);
        }

        if (saved == '\0') break;
    }

    free(data);
    return total;
}
