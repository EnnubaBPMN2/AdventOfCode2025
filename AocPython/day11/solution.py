import os
from utils.input_reader import run_solution


def part1(input_text: str) -> int:
    graph = parse_graph(input_text)
    return count_paths(graph, "you", "out")


def part2(input_text: str) -> int:
    graph = parse_graph(input_text)
    return count_paths_with_required_nodes(graph, "svr", "out", ["dac", "fft"])


def parse_graph(input_text: str):
    graph = {}
    lines = input_text.replace('\r', '').split('\n')

    for line in lines:
        if not line:
            continue

        parts = line.split(':')
        if len(parts) != 2:
            continue

        node = parts[0].strip()
        connections = parts[1].split()
        graph[node] = connections

    return graph


def count_paths(graph, start, end):
    path_count = 0
    visited = set()

    def dfs(current):
        nonlocal path_count

        # If we've reached the end, count this path
        if current == end:
            path_count += 1
            return

        # Mark current node as visited
        visited.add(current)

        # If this node has outgoing connections, explore them
        if current in graph:
            for next_node in graph[current]:
                # Only visit nodes we haven't visited in this path
                if next_node not in visited:
                    dfs(next_node)

        # Backtrack: unmark current node for other paths
        visited.remove(current)

    dfs(start)
    return path_count


def count_paths_with_required_nodes(graph, start, end, required_nodes):
    # Build index map for required nodes
    required_index = {node: i for i, node in enumerate(required_nodes)}

    visited = set()
    memo = {}

    def dfs(current, visited_required_bitmask):
        # If we've reached the end, check if all required nodes were visited
        if current == end:
            all_required = (1 << len(required_nodes)) - 1
            return 1 if visited_required_bitmask == all_required else 0

        # Check memoization (only when not in visited set to avoid cycle issues)
        key = (current, visited_required_bitmask)
        if current not in visited and key in memo:
            return memo[key]

        # Mark current node as visited (for cycle detection)
        visited.add(current)

        # Track if this is a required node
        new_visited_required_bitmask = visited_required_bitmask
        if current in required_index:
            new_visited_required_bitmask |= (1 << required_index[current])

        count = 0

        # If this node has outgoing connections, explore them
        if current in graph:
            for next_node in graph[current]:
                # Only visit nodes we haven't visited in this path
                if next_node not in visited:
                    count += dfs(next_node, new_visited_required_bitmask)

        # Backtrack: unmark current node for other paths
        visited.remove(current)

        # Memoize the result
        if current not in visited:
            memo[key] = count

        return count

    return dfs(start, 0)


def run():
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day11_test.txt")
    test_input_path2 = os.path.join(solution_root, "inputs", "day11_test_part2.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day11.txt")

    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=5)
    run_solution("Part 2", part2, test_input_path2, real_input_path, expected_test_result=2)
