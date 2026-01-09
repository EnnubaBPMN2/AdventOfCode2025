#include "day08.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void day08_run(void) {
    const char* test_path = "../inputs/day08_test.txt";
    const char* real_path = "../inputs/day08.txt";

    run_solution("Part 1", day08_part1, test_path, real_path, 40);
    run_solution("Part 2", day08_part2, test_path, real_path, 25272);
}

typedef struct {
    int x, y, z;
} Point3D;

typedef struct {
    double dist;
    int i, j;
} Edge;

static int* uf_parent;
static int* uf_size;

static int uf_find(int x) {
    if (uf_parent[x] != x) {
        uf_parent[x] = uf_find(uf_parent[x]);
    }
    return uf_parent[x];
}

static void uf_union(int x, int y) {
    int rx = uf_find(x);
    int ry = uf_find(y);
    if (rx != ry) {
        if (uf_size[rx] < uf_size[ry]) {
            uf_parent[rx] = ry;
            uf_size[ry] += uf_size[rx];
        } else {
            uf_parent[ry] = rx;
            uf_size[rx] += uf_size[ry];
        }
    }
}

static int compare_edges(const void* a, const void* b) {
    const Edge* ea = (const Edge*)a;
    const Edge* eb = (const Edge*)b;
    if (ea->dist < eb->dist) return -1;
    if (ea->dist > eb->dist) return 1;
    return 0;
}

int64_t day08_part1(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    // Parse points
    Point3D points[10000];
    int n = 0;

    char* line = strtok(data, "\r\n");
    while (line && n < 10000) {
        int x, y, z;
        if (sscanf(line, "%d,%d,%d", &x, &y, &z) == 3) {
            points[n].x = x;
            points[n].y = y;
            points[n].z = z;
            n++;
        }
        line = strtok(NULL, "\r\n");
    }

    free(data);

    if (n == 0) return 0;

    // Calculate all pairwise distances
    int edge_count = n * (n - 1) / 2;
    Edge* edges = (Edge*)malloc(edge_count * sizeof(Edge));
    int idx = 0;

    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            int64_t dx = points[i].x - points[j].x;
            int64_t dy = points[i].y - points[j].y;
            int64_t dz = points[i].z - points[j].z;
            edges[idx].dist = sqrt((double)(dx*dx + dy*dy + dz*dz));
            edges[idx].i = i;
            edges[idx].j = j;
            idx++;
        }
    }

    // Sort by distance
    qsort(edges, edge_count, sizeof(Edge), compare_edges);

    // Initialize Union-Find
    uf_parent = (int*)malloc(n * sizeof(int));
    uf_size = (int*)malloc(n * sizeof(int));
    for (int i = 0; i < n; i++) {
        uf_parent[i] = i;
        uf_size[i] = 1;
    }

    // Connect the 1000 shortest pairs (or 10 for test)
    int connections_to_make = (n == 20) ? 10 : 1000;

    for (int i = 0; i < edge_count && i < connections_to_make; i++) {
        uf_union(edges[i].i, edges[i].j);
    }

    // Count circuit sizes
    int* circuit_sizes = (int*)calloc(n, sizeof(int));
    for (int i = 0; i < n; i++) {
        circuit_sizes[uf_find(i)]++;
    }

    // Find three largest
    int sizes[10000];
    int size_count = 0;
    for (int i = 0; i < n; i++) {
        if (circuit_sizes[i] > 0) {
            sizes[size_count++] = circuit_sizes[i];
        }
    }

    // Sort descending
    for (int i = 0; i < size_count - 1; i++) {
        for (int j = i + 1; j < size_count; j++) {
            if (sizes[j] > sizes[i]) {
                int tmp = sizes[i];
                sizes[i] = sizes[j];
                sizes[j] = tmp;
            }
        }
    }

    int64_t result = 0;
    if (size_count >= 3) {
        result = (int64_t)sizes[0] * sizes[1] * sizes[2];
    } else if (size_count == 2) {
        result = (int64_t)sizes[0] * sizes[1];
    } else if (size_count == 1) {
        result = sizes[0];
    }

    free(edges);
    free(uf_parent);
    free(uf_size);
    free(circuit_sizes);

    return result;
}

int64_t day08_part2(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    // Parse points
    Point3D points[10000];
    int n = 0;

    char* line = strtok(data, "\r\n");
    while (line && n < 10000) {
        int x, y, z;
        if (sscanf(line, "%d,%d,%d", &x, &y, &z) == 3) {
            points[n].x = x;
            points[n].y = y;
            points[n].z = z;
            n++;
        }
        line = strtok(NULL, "\r\n");
    }

    free(data);

    if (n == 0) return 0;

    // Calculate all pairwise distances
    int edge_count = n * (n - 1) / 2;
    Edge* edges = (Edge*)malloc(edge_count * sizeof(Edge));
    int idx = 0;

    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            int64_t dx = points[i].x - points[j].x;
            int64_t dy = points[i].y - points[j].y;
            int64_t dz = points[i].z - points[j].z;
            edges[idx].dist = sqrt((double)(dx*dx + dy*dy + dz*dz));
            edges[idx].i = i;
            edges[idx].j = j;
            idx++;
        }
    }

    // Sort by distance
    qsort(edges, edge_count, sizeof(Edge), compare_edges);

    // Initialize Union-Find
    uf_parent = (int*)malloc(n * sizeof(int));
    uf_size = (int*)malloc(n * sizeof(int));
    for (int i = 0; i < n; i++) {
        uf_parent[i] = i;
        uf_size[i] = 1;
    }

    int circuit_count = n;
    int last_i = -1, last_j = -1;

    // Connect pairs until there's only one circuit
    for (int e = 0; e < edge_count; e++) {
        int i = edges[e].i;
        int j = edges[e].j;

        int ri = uf_find(i);
        int rj = uf_find(j);

        if (ri != rj) {
            uf_union(i, j);
            circuit_count--;
            last_i = i;
            last_j = j;

            if (circuit_count == 1) break;
        }
    }

    int64_t result = 0;
    if (last_i >= 0 && last_j >= 0) {
        result = (int64_t)points[last_i].x * points[last_j].x;
    }

    free(edges);
    free(uf_parent);
    free(uf_size);

    return result;
}
