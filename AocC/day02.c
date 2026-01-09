#include "day02.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void day02_run(void) {
    const char* test_path = "../inputs/day02_test.txt";
    const char* real_path = "../inputs/day02.txt";

    run_solution("Part 1", day02_part1, test_path, real_path, 1227775554);
    run_solution("Part 2", day02_part2, test_path, real_path, 4174379265);
}

static bool is_invalid_id_part1(int64_t id) {
    char s[21];
    snprintf(s, sizeof(s), "%lld", (long long)id);
    int len = (int)strlen(s);

    if (len % 2 != 0) return false;

    int half = len / 2;
    for (int i = 0; i < half; i++) {
        if (s[i] != s[half + i]) return false;
    }
    return true;
}

static bool is_invalid_id_part2(int64_t id) {
    char s[21];
    snprintf(s, sizeof(s), "%lld", (long long)id);
    int len = (int)strlen(s);

    // Try all possible pattern lengths L
    for (int L = 1; L <= len / 2; L++) {
        if (len % L == 0) {
            bool match = true;
            for (int i = L; i < len; i++) {
                if (s[i] != s[i % L]) {
                    match = false;
                    break;
                }
            }
            if (match) return true;
        }
    }
    return false;
}

static int64_t run_part(const char* input, bool (*validator)(int64_t)) {
    // Make a mutable copy
    char* data = strdup(input);
    if (!data) return 0;

    // Remove \r and \n
    char* src = data;
    char* dst = data;
    while (*src) {
        if (*src != '\r' && *src != '\n') {
            *dst++ = *src;
        }
        src++;
    }
    *dst = '\0';

    int64_t total = 0;
    char* token = strtok(data, ",");

    while (token) {
        // Parse range like "11-22"
        int64_t min_val, max_val;
        if (sscanf(token, "%lld-%lld", (long long*)&min_val, (long long*)&max_val) == 2) {
            for (int64_t i = min_val; i <= max_val; i++) {
                if (validator(i)) {
                    total += i;
                }
            }
        }
        token = strtok(NULL, ",");
    }

    free(data);
    return total;
}

int64_t day02_part1(const char* input) {
    return run_part(input, is_invalid_id_part1);
}

int64_t day02_part2(const char* input) {
    return run_part(input, is_invalid_id_part2);
}
