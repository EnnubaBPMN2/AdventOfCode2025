use crate::utils;
use std::collections::{HashMap, HashSet};

pub fn run() {
    let test_input_path = "../inputs/day11_test.txt";
    let test_input_path2 = "../inputs/day11_test_part2.txt";
    let real_input_path = "../inputs/day11.txt";

    utils::run_solution("Part 1", part1, test_input_path, real_input_path, Some(5));
    utils::run_solution("Part 2", part2, test_input_path2, real_input_path, Some(2));
}

pub fn part1(input: &str) -> i64 {
    let graph = parse_graph(input);
    count_paths(&graph, "you", "out")
}

pub fn part2(input: &str) -> i64 {
    let graph = parse_graph(input);
    count_paths_with_required_nodes(&graph, "svr", "out", &["dac", "fft"])
}

fn parse_graph(input: &str) -> HashMap<String, Vec<String>> {
    let mut graph = HashMap::new();
    let input = input.replace("\r", "");

    for line in input.lines() {
        if line.is_empty() {
            continue;
        }

        let parts: Vec<&str> = line.split(':').collect();
        if parts.len() != 2 {
            continue;
        }

        let node = parts[0].trim().to_string();
        let connections: Vec<String> = parts[1]
            .split_whitespace()
            .map(|s| s.to_string())
            .collect();

        graph.insert(node, connections);
    }

    graph
}

fn count_paths(graph: &HashMap<String, Vec<String>>, start: &str, end: &str) -> i64 {
    let mut path_count = 0;
    let mut visited = HashSet::new();

    fn dfs(
        current: &str,
        end: &str,
        graph: &HashMap<String, Vec<String>>,
        visited: &mut HashSet<String>,
        path_count: &mut i64,
    ) {
        // If we've reached the end, count this path
        if current == end {
            *path_count += 1;
            return;
        }

        // Mark current node as visited
        visited.insert(current.to_string());

        // If this node has outgoing connections, explore them
        if let Some(connections) = graph.get(current) {
            for next in connections {
                // Only visit nodes we haven't visited in this path
                if !visited.contains(next) {
                    dfs(next, end, graph, visited, path_count);
                }
            }
        }

        // Backtrack: unmark current node for other paths
        visited.remove(current);
    }

    dfs(start, end, graph, &mut visited, &mut path_count);
    path_count
}

fn count_paths_with_required_nodes(
    graph: &HashMap<String, Vec<String>>,
    start: &str,
    end: &str,
    required_nodes: &[&str],
) -> i64 {
    // Build index map for required nodes
    let mut required_index = HashMap::new();
    for (i, &node) in required_nodes.iter().enumerate() {
        required_index.insert(node, i);
    }

    let mut visited = HashSet::new();
    let mut memo: HashMap<(String, i32), i64> = HashMap::new();

    fn dfs(
        current: &str,
        end: &str,
        visited_required_bitmask: i32,
        graph: &HashMap<String, Vec<String>>,
        visited: &mut HashSet<String>,
        memo: &mut HashMap<(String, i32), i64>,
        required_index: &HashMap<&str, usize>,
        required_nodes: &[&str],
    ) -> i64 {
        // If we've reached the end, check if all required nodes were visited
        if current == end {
            let all_required = (1 << required_nodes.len()) - 1;
            return if visited_required_bitmask == all_required { 1 } else { 0 };
        }

        // Check memoization (only when not in visited set to avoid cycle issues)
        let key = (current.to_string(), visited_required_bitmask);
        if !visited.contains(current) {
            if let Some(&cached) = memo.get(&key) {
                return cached;
            }
        }

        // Mark current node as visited (for cycle detection)
        visited.insert(current.to_string());

        // Track if this is a required node
        let mut new_visited_required_bitmask = visited_required_bitmask;
        if let Some(&idx) = required_index.get(current) {
            new_visited_required_bitmask |= 1 << idx;
        }

        let mut count = 0;

        // If this node has outgoing connections, explore them
        if let Some(connections) = graph.get(current) {
            for next in connections {
                // Only visit nodes we haven't visited in this path
                if !visited.contains(next) {
                    count += dfs(
                        next,
                        end,
                        new_visited_required_bitmask,
                        graph,
                        visited,
                        memo,
                        required_index,
                        required_nodes,
                    );
                }
            }
        }

        // Backtrack: unmark current node for other paths
        visited.remove(current);

        // Memoize the result
        if !visited.contains(current) {
            memo.insert(key, count);
        }

        count
    }

    dfs(
        start,
        end,
        0,
        graph,
        &mut visited,
        &mut memo,
        &required_index,
        required_nodes,
    )
}
