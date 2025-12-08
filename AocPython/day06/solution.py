import os
from utils.input_reader import run_solution

def part1(input_text: str) -> int:
    lines = input_text.replace('\r', '').split('\n')
    lines = [line for line in lines if line]

    if not lines:
        return 0

    height = len(lines)
    width = max(len(line) for line in lines)

    # Pad lines to ensure they are all the same length
    grid = [line.ljust(width) for line in lines]

    problems = []
    start_col = None

    for col in range(width):
        is_empty_col = True
        for row in range(height):
            if grid[row][col] != ' ':
                is_empty_col = False
                break

        if not is_empty_col:
            if start_col is None:
                start_col = col
        else:
            if start_col is not None:
                # End of a block
                problems.append(parse_problem(grid, start_col, col - 1))
                start_col = None

    # Handle last block if it extends to the edge
    if start_col is not None:
        problems.append(parse_problem(grid, start_col, width - 1))

    total = 0
    for numbers, op in problems:
        result = numbers[0]
        for i in range(1, len(numbers)):
            if op == '+':
                result += numbers[i]
            elif op == '*':
                result *= numbers[i]
        total += result

    return total

def parse_problem(grid, start_col, end_col):
    numbers = []
    op = ' '

    height = len(grid)
    width = end_col - start_col + 1

    # Numbers are in all rows except the last
    for row in range(height - 1):
        substring = grid[row][start_col:end_col + 1].strip()
        if substring:
            try:
                num = int(substring)
                numbers.append(num)
            except ValueError:
                pass

    # Operator is in the last row
    op_string = grid[height - 1][start_col:end_col + 1].strip()
    if op_string:
        op = op_string[0]

    return (numbers, op)

def part2(input_text: str) -> int:
    lines = input_text.replace('\r', '').split('\n')
    lines = [line for line in lines if line]

    if not lines:
        return 0

    height = len(lines)
    width = max(len(line) for line in lines)

    # Pad lines to ensure they are all the same length
    grid = [line.ljust(width) for line in lines]

    problems = []
    start_col = None

    for col in range(width):
        is_empty_col = True
        for row in range(height):
            if grid[row][col] != ' ':
                is_empty_col = False
                break

        if not is_empty_col:
            if start_col is None:
                start_col = col
        else:
            if start_col is not None:
                # End of a block - parse reading right-to-left
                problems.append(parse_problem_right_to_left(grid, start_col, col - 1))
                start_col = None

    # Handle last block if it extends to the edge
    if start_col is not None:
        problems.append(parse_problem_right_to_left(grid, start_col, width - 1))

    total = 0
    for numbers, op in problems:
        result = numbers[0]
        for i in range(1, len(numbers)):
            if op == '+':
                result += numbers[i]
            elif op == '*':
                result *= numbers[i]
        total += result

    return total

def parse_problem_right_to_left(grid, start_col, end_col):
    numbers = []
    op = ' '

    height = len(grid)

    # Read each column from right to left
    for col in range(end_col, start_col - 1, -1):
        digit_chars = []

        # Read digits from top to bottom in this column (rows 0 to height-2, excluding operator row)
        for row in range(height - 1):
            c = grid[row][col]
            if c != ' ':
                digit_chars.append(c)

        # Build number from these digits
        if digit_chars:
            num_str = ''.join(digit_chars)
            try:
                num = int(num_str)
                numbers.append(num)
            except ValueError:
                pass

    # Operator is in the last row - find it anywhere in this block
    for col in range(start_col, end_col + 1):
        c = grid[height - 1][col]
        if c in ['+', '*']:
            op = c
            break

    return (numbers, op)

def run():
    # Go up two levels to reach solution root, then into inputs
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day06_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day06.txt")

    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=4277556)
    run_solution("Part 2", part2, test_input_path, real_input_path, expected_test_result=3263827)
