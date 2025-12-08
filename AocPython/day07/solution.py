import os
from utils.input_reader import run_solution

def part1(input_text: str) -> int:
    lines = input_text.replace('\r', '').split('\n')
    lines = [line for line in lines if line]

    if not lines:
        return 0

    grid = [list(line) for line in lines]
    height = len(grid)
    width = len(grid[0])

    # Find starting position 'S'
    start_row, start_col = -1, -1
    for row in range(height):
        for col in range(width):
            if grid[row][col] == 'S':
                start_row, start_col = row, col
                break
        if start_row != -1:
            break

    # Simulate beams moving downward
    current_beams = {start_col}
    split_count = 0

    for row in range(start_row + 1, height):
        next_beams = set()

        for col in current_beams:
            cell = grid[row][col]

            if cell == '^':
                # Splitter encountered
                split_count += 1

                # Add beams to left and right
                if col - 1 >= 0:
                    next_beams.add(col - 1)
                if col + 1 < width:
                    next_beams.add(col + 1)
            else:
                # Empty space - beam continues downward
                next_beams.add(col)

        current_beams = next_beams

        # If no beams left, we're done
        if not current_beams:
            break

    return split_count

def part2(input_text: str) -> int:
    lines = input_text.replace('\r', '').split('\n')
    lines = [line for line in lines if line]

    if not lines:
        return 0

    grid = [list(line) for line in lines]
    height = len(grid)
    width = len(grid[0])

    # Find starting position 'S'
    start_row, start_col = -1, -1
    for row in range(height):
        for col in range(width):
            if grid[row][col] == 'S':
                start_row, start_col = row, col
                break
        if start_row != -1:
            break

    # For Part 2, track the number of distinct timelines/paths
    current_paths = {start_col: 1}

    for row in range(start_row + 1, height):
        next_paths = {}

        for col, path_count in current_paths.items():
            cell = grid[row][col]

            if cell == '^':
                # Splitter - particle takes both paths (quantum splitting)
                if col - 1 >= 0:
                    if col - 1 not in next_paths:
                        next_paths[col - 1] = 0
                    next_paths[col - 1] += path_count
                if col + 1 < width:
                    if col + 1 not in next_paths:
                        next_paths[col + 1] = 0
                    next_paths[col + 1] += path_count
            else:
                # Empty space - particle continues downward
                if col not in next_paths:
                    next_paths[col] = 0
                next_paths[col] += path_count

        current_paths = next_paths

        # If no paths left, we're done
        if not current_paths:
            break

    # Sum all timelines that reach the bottom
    return sum(current_paths.values())

def run():
    # Go up two levels to reach solution root, then into inputs
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day07_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day07.txt")

    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=21)
    run_solution("Part 2", part2, test_input_path, real_input_path, expected_test_result=40)
