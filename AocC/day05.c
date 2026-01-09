#include "day05.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void day05_run(void) {
    const char* test_path = "../inputs/day05_test.txt";
    const char* real_path = "../inputs/day05.txt";

    run_solution("Part 1", day05_part1, test_path, real_path, 3);
    run_solution("Part 2", day05_part2, test_path, real_path, 14);
}

typedef struct {
    int64_t start;
    int64_t end;
} Range;

static int compare_ranges(const void* a, const void* b) {
    const Range* ra = (const Range*)a;
    const Range* rb = (const Range*)b;
    if (ra->start < rb->start) return -1;
    if (ra->start > rb->start) return 1;
    return 0;
}

int64_t day05_part1(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    // Find the blank line separator
    char* separator = strstr(data, "\n\n");
    if (!separator) {
        separator = strstr(data, "\r\n\r\n");
    }

    if (!separator) {
        free(data);
        return 0;
    }

    *separator = '\0';
    char* ranges_section = data;
    char* ids_section = separator + 2;
    while (*ids_section == '\n' || *ids_section == '\r') ids_section++;

    // Parse ranges
    Range ranges[1000];
    int range_count = 0;

    char* line = strtok(ranges_section, "\r\n");
    while (line && range_count < 1000) {
        int64_t start, end;
        if (sscanf(line, "%lld-%lld", (long long*)&start, (long long*)&end) == 2) {
            ranges[range_count].start = start;
            ranges[range_count].end = end;
            range_count++;
        }
        line = strtok(NULL, "\r\n");
    }

    // Parse IDs
    int64_t ids[10000];
    int id_count = 0;

    char* ids_data = strdup(ids_section);
    line = strtok(ids_data, "\r\n");
    while (line && id_count < 10000) {
        int64_t id;
        if (sscanf(line, "%lld", (long long*)&id) == 1) {
            ids[id_count++] = id;
        }
        line = strtok(NULL, "\r\n");
    }
    free(ids_data);

    // Count fresh IDs
    int64_t fresh_count = 0;
    for (int i = 0; i < id_count; i++) {
        for (int j = 0; j < range_count; j++) {
            if (ids[i] >= ranges[j].start && ids[i] <= ranges[j].end) {
                fresh_count++;
                break;
            }
        }
    }

    free(data);
    return fresh_count;
}

int64_t day05_part2(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    // Find the blank line separator (only use range section)
    char* separator = strstr(data, "\n\n");
    if (!separator) {
        separator = strstr(data, "\r\n\r\n");
    }

    if (separator) {
        *separator = '\0';
    }

    // Parse ranges
    Range ranges[1000];
    int range_count = 0;

    char* line = strtok(data, "\r\n");
    while (line && range_count < 1000) {
        int64_t start, end;
        if (sscanf(line, "%lld-%lld", (long long*)&start, (long long*)&end) == 2) {
            ranges[range_count].start = start;
            ranges[range_count].end = end;
            range_count++;
        }
        line = strtok(NULL, "\r\n");
    }

    if (range_count == 0) {
        free(data);
        return 0;
    }

    // Sort ranges by start
    qsort(ranges, range_count, sizeof(Range), compare_ranges);

    // Merge overlapping/adjacent ranges
    Range merged[1000];
    int merged_count = 0;

    merged[0] = ranges[0];
    merged_count = 1;

    for (int i = 1; i < range_count; i++) {
        Range* current = &merged[merged_count - 1];
        if (ranges[i].start <= current->end + 1) {
            if (ranges[i].end > current->end) {
                current->end = ranges[i].end;
            }
        } else {
            merged[merged_count++] = ranges[i];
        }
    }

    // Sum total fresh IDs
    int64_t total = 0;
    for (int i = 0; i < merged_count; i++) {
        total += merged[i].end - merged[i].start + 1;
    }

    free(data);
    return total;
}
