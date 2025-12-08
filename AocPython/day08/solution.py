import os
import math
from utils.input_reader import run_solution

def part1(input_text: str) -> int:
    lines = input_text.replace('\r', '').split('\n')
    lines = [line for line in lines if line]

    if not lines:
        return 0

    # Parse junction box positions
    points = []
    for line in lines:
        parts = line.split(',')
        if len(parts) == 3:
            points.append((int(parts[0]), int(parts[1]), int(parts[2])))

    n = len(points)

    # Calculate all pairwise distances
    distances = []
    for i in range(n):
        for j in range(i + 1, n):
            p1 = points[i]
            p2 = points[j]
            dist = math.sqrt(
                (p1[0] - p2[0]) ** 2 +
                (p1[1] - p2[1]) ** 2 +
                (p1[2] - p2[2]) ** 2
            )
            distances.append((dist, i, j))

    # Sort by distance
    distances.sort()

    # Union-Find
    parent = list(range(n))
    size = [1] * n

    def find(x):
        if parent[x] != x:
            parent[x] = find(parent[x])
        return parent[x]

    def union(x, y):
        root_x = find(x)
        root_y = find(y)
        if root_x != root_y:
            if size[root_x] < size[root_y]:
                parent[root_x] = root_y
                size[root_y] += size[root_x]
            else:
                parent[root_y] = root_x
                size[root_x] += size[root_y]

    # Connect the 1000 shortest pairs (or 10 for test)
    connections_to_make = 10 if n == 20 else 1000
    connections_made = 0

    for dist, i, j in distances:
        if connections_made >= connections_to_make:
            break
        union(i, j)
        connections_made += 1

    # Find all unique circuits and their sizes
    circuit_sizes = {}
    for i in range(n):
        root = find(i)
        if root not in circuit_sizes:
            circuit_sizes[root] = 0
        circuit_sizes[root] += 1

    # Get three largest circuit sizes
    sizes = sorted(circuit_sizes.values(), reverse=True)

    if len(sizes) >= 3:
        return sizes[0] * sizes[1] * sizes[2]
    elif len(sizes) == 2:
        return sizes[0] * sizes[1]
    elif len(sizes) == 1:
        return sizes[0]

    return 0

def part2(input_text: str) -> int:
    lines = input_text.replace('\r', '').split('\n')
    lines = [line for line in lines if line]

    if not lines:
        return 0

    # Parse junction box positions
    points = []
    for line in lines:
        parts = line.split(',')
        if len(parts) == 3:
            points.append((int(parts[0]), int(parts[1]), int(parts[2])))

    n = len(points)

    # Calculate all pairwise distances
    distances = []
    for i in range(n):
        for j in range(i + 1, n):
            p1 = points[i]
            p2 = points[j]
            dist = math.sqrt(
                (p1[0] - p2[0]) ** 2 +
                (p1[1] - p2[1]) ** 2 +
                (p1[2] - p2[2]) ** 2
            )
            distances.append((dist, i, j))

    # Sort by distance
    distances.sort()

    # Union-Find
    parent = list(range(n))
    size = [1] * n

    def find(x):
        if parent[x] != x:
            parent[x] = find(parent[x])
        return parent[x]

    def union(x, y):
        root_x = find(x)
        root_y = find(y)
        if root_x != root_y:
            if size[root_x] < size[root_y]:
                parent[root_x] = root_y
                size[root_y] += size[root_x]
            else:
                parent[root_y] = root_x
                size[root_x] += size[root_y]
            return True  # Actually connected
        return False  # Already connected

    def count_circuits():
        roots = set()
        for i in range(n):
            roots.add(find(i))
        return len(roots)

    # Connect pairs until there's only one circuit
    last_i, last_j = -1, -1
    for dist, i, j in distances:
        if union(i, j):
            last_i, last_j = i, j
            if count_circuits() == 1:
                break

    # Multiply X coordinates of last two connected junction boxes
    if last_i >= 0 and last_j >= 0:
        return points[last_i][0] * points[last_j][0]

    return 0

def run():
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day08_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day08.txt")

    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=40)
    run_solution("Part 2", part2, test_input_path, real_input_path, expected_test_result=25272)
