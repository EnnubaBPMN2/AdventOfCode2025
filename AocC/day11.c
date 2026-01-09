#include "day11.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void day11_run(void) {
    const char* test_path = "../inputs/day11_test.txt";
    const char* test_path2 = "../inputs/day11_test_part2.txt";
    const char* real_path = "../inputs/day11.txt";

    run_solution("Part 1", day11_part1, test_path, real_path, 5);
    run_solution("Part 2", day11_part2, test_path2, real_path, 2);
}

#define MAX_NODES 1000
#define MAX_EDGES 100

typedef struct {
    char name[32];
    int edges[MAX_EDGES];
    int edge_count;
} Node;

typedef struct {
    Node nodes[MAX_NODES];
    int node_count;
} Graph;

static int find_or_add_node(Graph* g, const char* name) {
    for (int i = 0; i < g->node_count; i++) {
        if (strcmp(g->nodes[i].name, name) == 0) {
            return i;
        }
    }
    if (g->node_count >= MAX_NODES) return -1;

    int idx = g->node_count++;
    strncpy(g->nodes[idx].name, name, 31);
    g->nodes[idx].name[31] = '\0';
    g->nodes[idx].edge_count = 0;
    return idx;
}

static Graph parse_graph(const char* input) {
    Graph g = {0};
    char* data = strdup(input);
    if (!data) return g;

    // First pass: collect all lines without using strtok (which is problematic with nested usage)
    char* lines[1000];
    int line_count = 0;

    char* ptr = data;
    while (*ptr && line_count < 1000) {
        lines[line_count++] = ptr;
        while (*ptr && *ptr != '\n' && *ptr != '\r') ptr++;
        if (*ptr == '\r') *ptr++ = '\0';
        if (*ptr == '\n') *ptr++ = '\0';
    }

    // Parse each line
    for (int i = 0; i < line_count; i++) {
        char* line = lines[i];
        if (strlen(line) == 0) continue;

        char* colon = strchr(line, ':');
        if (!colon) continue;

        *colon = '\0';

        // Trim whitespace from node name
        char* node_name = line;
        while (*node_name == ' ' || *node_name == '\t') node_name++;
        char* end = node_name + strlen(node_name) - 1;
        while (end > node_name && (*end == ' ' || *end == '\t')) *end-- = '\0';

        int node_idx = find_or_add_node(&g, node_name);
        if (node_idx < 0) continue;

        // Parse targets
        char* targets = colon + 1;
        char* token = targets;
        while (*token) {
            // Skip whitespace
            while (*token == ' ' || *token == '\t') token++;
            if (*token == '\0') break;

            // Find end of token
            char* token_end = token;
            while (*token_end && *token_end != ' ' && *token_end != '\t') token_end++;

            char saved = *token_end;
            *token_end = '\0';

            if (strlen(token) > 0) {
                int target_idx = find_or_add_node(&g, token);
                if (target_idx >= 0 && g.nodes[node_idx].edge_count < MAX_EDGES) {
                    g.nodes[node_idx].edges[g.nodes[node_idx].edge_count++] = target_idx;
                }
            }

            if (saved == '\0') break;
            token = token_end + 1;
        }
    }

    free(data);
    return g;
}

// Part 1: Simple path counting in a DAG (no visited tracking needed for DAG)
static int64_t memo1[MAX_NODES];
static bool memo1_valid[MAX_NODES];

static int64_t count_paths_dag(Graph* g, int current, int end_idx) {
    if (current == end_idx) return 1;
    if (memo1_valid[current]) return memo1[current];

    int64_t count = 0;
    Node* node = &g->nodes[current];
    for (int i = 0; i < node->edge_count; i++) {
        count += count_paths_dag(g, node->edges[i], end_idx);
    }

    memo1[current] = count;
    memo1_valid[current] = true;
    return count;
}

int64_t day11_part1(const char* input) {
    Graph g = parse_graph(input);

    int start_idx = -1, end_idx = -1;
    for (int i = 0; i < g.node_count; i++) {
        if (strcmp(g.nodes[i].name, "you") == 0) start_idx = i;
        if (strcmp(g.nodes[i].name, "out") == 0) end_idx = i;
    }

    if (start_idx < 0 || end_idx < 0) return 0;

    memset(memo1_valid, 0, sizeof(memo1_valid));

    return count_paths_dag(&g, start_idx, end_idx);
}

// Part 2: Path counting with required nodes (dac, fft must be visited)
static int64_t memo2[MAX_NODES][4];
static bool memo2_valid[MAX_NODES][4];

static int64_t count_paths_required_dag(Graph* g, int current, int end_idx,
                                        int dac_idx, int fft_idx, int mask) {
    int new_mask = mask;
    if (dac_idx >= 0 && current == dac_idx) new_mask |= 1;
    if (fft_idx >= 0 && current == fft_idx) new_mask |= 2;

    if (current == end_idx) {
        bool needs_dac = (dac_idx >= 0);
        bool needs_fft = (fft_idx >= 0);
        if (needs_dac && !(new_mask & 1)) return 0;
        if (needs_fft && !(new_mask & 2)) return 0;
        return 1;
    }

    if (memo2_valid[current][mask]) {
        return memo2[current][mask];
    }

    int64_t count = 0;
    Node* node = &g->nodes[current];
    for (int i = 0; i < node->edge_count; i++) {
        count += count_paths_required_dag(g, node->edges[i], end_idx, dac_idx, fft_idx, new_mask);
    }

    memo2[current][mask] = count;
    memo2_valid[current][mask] = true;
    return count;
}

int64_t day11_part2(const char* input) {
    Graph g = parse_graph(input);

    int start_idx = -1, end_idx = -1, dac_idx = -1, fft_idx = -1;
    for (int i = 0; i < g.node_count; i++) {
        if (strcmp(g.nodes[i].name, "svr") == 0) start_idx = i;
        if (strcmp(g.nodes[i].name, "out") == 0) end_idx = i;
        if (strcmp(g.nodes[i].name, "dac") == 0) dac_idx = i;
        if (strcmp(g.nodes[i].name, "fft") == 0) fft_idx = i;
    }

    if (start_idx < 0 || end_idx < 0) return 0;

    memset(memo2_valid, 0, sizeof(memo2_valid));

    return count_paths_required_dag(&g, start_idx, end_idx, dac_idx, fft_idx, 0);
}
