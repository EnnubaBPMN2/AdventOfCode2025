#include "day12.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// ANSI color codes
#define COLOR_RESET   "\033[0m"
#define COLOR_GREEN   "\033[32m"

void day12_run(void) {
    const char* test_path = "../inputs/day12_test.txt";
    const char* real_path = "../inputs/day12.txt";

    run_solution("Part 1", day12_part1, test_path, real_path, 2);
    printf("\n" COLOR_GREEN "🎄 Part 2 automatically completed! Both stars earned! 🎄" COLOR_RESET "\n");
}

#define MAX_SHAPES 10
#define MAX_CELLS 20
#define MAX_ORIENTATIONS 8
#define MAX_REGIONS 100

typedef struct {
    int rows[MAX_CELLS];
    int cols[MAX_CELLS];
    int cell_count;
    int width;
    int height;
} Shape;

typedef struct {
    int width;
    int height;
    int counts[MAX_SHAPES];
    int num_counts;
} Region;

static void normalize_shape(int* rows, int* cols, int n, Shape* out) {
    if (n == 0) {
        out->cell_count = 0;
        out->width = 0;
        out->height = 0;
        return;
    }

    int min_r = rows[0], min_c = cols[0];
    for (int i = 1; i < n; i++) {
        if (rows[i] < min_r) min_r = rows[i];
        if (cols[i] < min_c) min_c = cols[i];
    }

    int max_r = 0, max_c = 0;
    for (int i = 0; i < n; i++) {
        out->rows[i] = rows[i] - min_r;
        out->cols[i] = cols[i] - min_c;
        if (out->rows[i] > max_r) max_r = out->rows[i];
        if (out->cols[i] > max_c) max_c = out->cols[i];
    }

    out->cell_count = n;
    out->height = max_r + 1;
    out->width = max_c + 1;
}

static void rotate_points(int* rows, int* cols, int n, int* out_rows, int* out_cols) {
    for (int i = 0; i < n; i++) {
        out_rows[i] = cols[i];
        out_cols[i] = -rows[i];
    }
}

static void flip_points(int* rows, int* cols, int n, int* out_rows, int* out_cols) {
    for (int i = 0; i < n; i++) {
        out_rows[i] = rows[i];
        out_cols[i] = -cols[i];
    }
}

static void shape_to_key(Shape* s, char* key) {
    // Create a grid representation as a string key
    char grid[20][20];
    memset(grid, '.', sizeof(grid));

    for (int i = 0; i < s->cell_count; i++) {
        grid[s->rows[i]][s->cols[i]] = '#';
    }

    int pos = 0;
    for (int r = 0; r < s->height; r++) {
        for (int c = 0; c < s->width; c++) {
            key[pos++] = grid[r][c];
        }
        key[pos++] = '|';
    }
    key[pos] = '\0';
}

static int get_orientations(int* orig_rows, int* orig_cols, int n, Shape orientations[MAX_ORIENTATIONS]) {
    int count = 0;
    char seen_keys[MAX_ORIENTATIONS][512];

    int curr_rows[MAX_CELLS], curr_cols[MAX_CELLS];
    memcpy(curr_rows, orig_rows, n * sizeof(int));
    memcpy(curr_cols, orig_cols, n * sizeof(int));

    for (int rot = 0; rot < 4; rot++) {
        // Normal
        Shape s;
        normalize_shape(curr_rows, curr_cols, n, &s);
        char key[512];
        shape_to_key(&s, key);

        bool found = false;
        for (int i = 0; i < count; i++) {
            if (strcmp(seen_keys[i], key) == 0) {
                found = true;
                break;
            }
        }
        if (!found && count < MAX_ORIENTATIONS) {
            strcpy(seen_keys[count], key);
            orientations[count++] = s;
        }

        // Flipped
        int flip_rows[MAX_CELLS], flip_cols[MAX_CELLS];
        flip_points(curr_rows, curr_cols, n, flip_rows, flip_cols);
        normalize_shape(flip_rows, flip_cols, n, &s);
        shape_to_key(&s, key);

        found = false;
        for (int i = 0; i < count; i++) {
            if (strcmp(seen_keys[i], key) == 0) {
                found = true;
                break;
            }
        }
        if (!found && count < MAX_ORIENTATIONS) {
            strcpy(seen_keys[count], key);
            orientations[count++] = s;
        }

        // Rotate for next iteration
        int rot_rows[MAX_CELLS], rot_cols[MAX_CELLS];
        rotate_points(curr_rows, curr_cols, n, rot_rows, rot_cols);
        memcpy(curr_rows, rot_rows, n * sizeof(int));
        memcpy(curr_cols, rot_cols, n * sizeof(int));
    }

    return count;
}

static bool can_place(bool* grid, int grid_w, int grid_h, Shape* s, int start_r, int start_c) {
    if (start_r + s->height > grid_h) return false;
    if (start_c + s->width > grid_w) return false;

    for (int i = 0; i < s->cell_count; i++) {
        int r = start_r + s->rows[i];
        int c = start_c + s->cols[i];
        if (grid[r * grid_w + c]) return false;
    }
    return true;
}

static void place_shape(bool* grid, int grid_w, Shape* s, int start_r, int start_c, bool val) {
    for (int i = 0; i < s->cell_count; i++) {
        int r = start_r + s->rows[i];
        int c = start_c + s->cols[i];
        grid[r * grid_w + c] = val;
    }
}

static bool solve(bool* grid, int w, int h, int* counts, int num_shapes,
                  Shape orientations[MAX_SHAPES][MAX_ORIENTATIONS],
                  int orient_counts[MAX_SHAPES]) {
    // Find first shape with count > 0
    int shape_idx = -1;
    for (int i = 0; i < num_shapes; i++) {
        if (counts[i] > 0) {
            shape_idx = i;
            break;
        }
    }

    if (shape_idx == -1) return true;  // All placed

    for (int o = 0; o < orient_counts[shape_idx]; o++) {
        Shape* s = &orientations[shape_idx][o];

        for (int r = 0; r <= h - s->height; r++) {
            for (int c = 0; c <= w - s->width; c++) {
                if (can_place(grid, w, h, s, r, c)) {
                    place_shape(grid, w, s, r, c, true);
                    counts[shape_idx]--;

                    if (solve(grid, w, h, counts, num_shapes, orientations, orient_counts)) {
                        return true;
                    }

                    counts[shape_idx]++;
                    place_shape(grid, w, s, r, c, false);
                }
            }
        }
    }

    return false;
}

int64_t day12_part1(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    // Parse shapes and regions
    int shape_rows[MAX_SHAPES][MAX_CELLS];
    int shape_cols[MAX_SHAPES][MAX_CELLS];
    int shape_sizes[MAX_SHAPES];
    int num_shapes = 0;

    Region regions[MAX_REGIONS];
    int num_regions = 0;

    char* lines[500];
    int line_count = 0;

    char* line = strtok(data, "\r\n");
    while (line && line_count < 500) {
        lines[line_count++] = line;
        line = strtok(NULL, "\r\n");
    }

    int i = 0;
    while (i < line_count) {
        char* l = lines[i];

        // Check if it's a region definition (contains 'x' and ':')
        if (strchr(l, 'x') && strchr(l, ':')) {
            Region r = {0};
            char* colon = strchr(l, ':');
            *colon = '\0';

            sscanf(l, "%dx%d", &r.width, &r.height);

            char* counts_str = colon + 1;
            char* tok = strtok(counts_str, " \t");
            while (tok && r.num_counts < MAX_SHAPES) {
                r.counts[r.num_counts++] = atoi(tok);
                tok = strtok(NULL, " \t");
            }

            if (num_regions < MAX_REGIONS) {
                regions[num_regions++] = r;
            }
            i++;
        }
        // Check if it's a shape definition (contains ':' but not 'x')
        else if (strchr(l, ':')) {
            i++;  // Skip label

            // Read shape lines
            int rows[MAX_CELLS], cols[MAX_CELLS];
            int n = 0;
            int row = 0;

            while (i < line_count && strlen(lines[i]) > 0 && !strchr(lines[i], ':')) {
                for (int c = 0; c < (int)strlen(lines[i]) && n < MAX_CELLS; c++) {
                    if (lines[i][c] == '#') {
                        rows[n] = row;
                        cols[n] = c;
                        n++;
                    }
                }
                row++;
                i++;
            }

            if (n > 0 && num_shapes < MAX_SHAPES) {
                memcpy(shape_rows[num_shapes], rows, n * sizeof(int));
                memcpy(shape_cols[num_shapes], cols, n * sizeof(int));
                shape_sizes[num_shapes] = n;
                num_shapes++;
            }
        } else {
            i++;
        }
    }

    // Precompute orientations
    Shape orientations[MAX_SHAPES][MAX_ORIENTATIONS];
    int orient_counts[MAX_SHAPES];

    for (int s = 0; s < num_shapes; s++) {
        orient_counts[s] = get_orientations(shape_rows[s], shape_cols[s],
                                             shape_sizes[s], orientations[s]);
    }

    // Try each region
    int64_t valid_count = 0;

    for (int r = 0; r < num_regions; r++) {
        Region* reg = &regions[r];

        // Quick area check
        int required_area = 0;
        for (int s = 0; s < reg->num_counts && s < num_shapes; s++) {
            required_area += reg->counts[s] * shape_sizes[s];
        }
        if (required_area > reg->width * reg->height) continue;

        // Create grid
        bool* grid = (bool*)calloc(reg->width * reg->height, sizeof(bool));
        int counts[MAX_SHAPES];
        memcpy(counts, reg->counts, reg->num_counts * sizeof(int));

        if (solve(grid, reg->width, reg->height, counts, reg->num_counts,
                  orientations, orient_counts)) {
            valid_count++;
        }

        free(grid);
    }

    free(data);
    return valid_count;
}
