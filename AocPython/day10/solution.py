import os
import re
from utils.input_reader import run_solution


def part1(input_text: str) -> int:
    lines = input_text.replace('\r', '').split('\n')
    lines = [line for line in lines if line]

    total_presses = 0

    for line in lines:
        target, buttons = parse_machine(line)
        min_presses = solve_gaussian_elimination(target, buttons)
        total_presses += min_presses

    return total_presses


def part2(input_text: str) -> int:
    lines = input_text.replace('\r', '').split('\n')
    lines = [line for line in lines if line]

    total_presses = 0

    for line in lines:
        targets, buttons = parse_machine_part2(line)
        min_presses = solve_integer_linear_programming(targets, buttons)
        total_presses += min_presses

    return total_presses


def parse_machine(line):
    # Extract indicator pattern [.##.]
    indicator_match = re.search(r'\[(\.|\#)+\]', line)
    indicator = indicator_match.group(0).strip('[]')
    target = [c == '#' for c in indicator]

    # Extract button patterns
    button_matches = re.findall(r'\([\d,]+\)', line)
    buttons = []

    for match in button_matches:
        button_str = match.strip('()')
        indices = [int(x) for x in button_str.split(',')]

        button = [False] * len(target)
        for idx in indices:
            button[idx] = True
        buttons.append(button)

    return target, buttons


def solve_gaussian_elimination(target, buttons):
    num_lights = len(target)
    num_buttons = len(buttons)

    # Build augmented matrix [A | b] for GF(2)
    matrix = [[buttons[button][light] for button in range(num_buttons)] + [target[light]]
              for light in range(num_lights)]

    # Perform Gaussian elimination in GF(2)
    pivot = [-1] * num_lights

    col = 0
    row = 0
    while row < num_lights and col < num_buttons:
        # Find pivot
        pivot_row = None
        for r in range(row, num_lights):
            if matrix[r][col]:
                pivot_row = r
                break

        if pivot_row is None:
            col += 1
            continue

        # Swap rows
        if pivot_row != row:
            matrix[row], matrix[pivot_row] = matrix[pivot_row], matrix[row]

        pivot[row] = col

        # Eliminate column
        for r in range(num_lights):
            if r != row and matrix[r][col]:
                for c in range(num_buttons + 1):
                    matrix[r][c] ^= matrix[row][c]

        row += 1
        col += 1

    # Check for inconsistency
    for r in range(num_lights):
        all_zero = all(not matrix[r][c] for c in range(num_buttons))
        if all_zero and matrix[r][num_buttons]:
            return float('inf')

    # Find free variables
    free_vars = []
    for c in range(num_buttons):
        is_pivot = any(pivot[r] == c for r in range(num_lights))
        if not is_pivot:
            free_vars.append(c)

    min_presses = float('inf')
    max_combinations = min(1 << len(free_vars), 1 << 15)

    for mask in range(max_combinations):
        solution = [False] * num_buttons

        # Set free variables based on mask
        for i in range(min(len(free_vars), 15)):
            solution[free_vars[i]] = ((mask >> i) & 1) == 1

        # Back-substitute for pivot variables
        for r in range(num_lights - 1, -1, -1):
            if pivot[r] == -1:
                continue

            pivot_col = pivot[r]
            val = matrix[r][num_buttons]
            for c in range(pivot_col + 1, num_buttons):
                if matrix[r][c] and solution[c]:
                    val ^= True
            solution[pivot_col] = val

        # Count presses
        presses = sum(solution)
        min_presses = min(min_presses, presses)

    return min_presses


def parse_machine_part2(line):
    # Extract joltage requirements {3,5,4,7}
    jolts_match = re.search(r'\{[\d,]+\}', line)
    jolts_str = jolts_match.group(0).strip('{}')
    targets = [int(x) for x in jolts_str.split(',')]

    # Extract button patterns
    button_matches = re.findall(r'\([\d,]+\)', line)
    buttons = []

    for match in button_matches:
        button_str = match.strip('()')
        indices = [int(x) for x in button_str.split(',')]

        button = [0] * len(targets)
        for idx in indices:
            button[idx] = 1
        buttons.append(button)

    return targets, buttons


def solve_integer_linear_programming(targets, buttons):
    num_counters = len(targets)
    num_buttons = len(buttons)

    # Build matrix [A | b]
    matrix = [[float(buttons[button][counter]) for button in range(num_buttons)] + [float(targets[counter])]
              for counter in range(num_counters)]

    # Perform Gaussian elimination to get RREF
    pivot = [-1] * num_counters

    col = 0
    row = 0
    while row < num_counters and col < num_buttons:
        # Find pivot
        pivot_row = None
        for r in range(row, num_counters):
            if abs(matrix[r][col]) > 1e-9:
                pivot_row = r
                break

        if pivot_row is None:
            col += 1
            continue

        # Swap rows
        if pivot_row != row:
            matrix[row], matrix[pivot_row] = matrix[pivot_row], matrix[row]

        pivot[row] = col

        # Scale pivot row
        pivot_val = matrix[row][col]
        for c in range(num_buttons + 1):
            matrix[row][c] /= pivot_val

        # Eliminate column
        for r in range(num_counters):
            if r != row and abs(matrix[r][col]) > 1e-9:
                factor = matrix[r][col]
                for c in range(num_buttons + 1):
                    matrix[r][c] -= factor * matrix[row][c]

        row += 1
        col += 1

    # Find free variables
    free_vars = []
    for c in range(num_buttons):
        is_pivot = any(pivot[r] == c for r in range(num_counters))
        if not is_pivot:
            free_vars.append(c)

    min_presses = float('inf')

    # For systems with no free variables, there's a unique solution
    if not free_vars:
        solution = [0] * num_buttons

        for r in range(num_counters):
            if pivot[r] == -1:
                continue

            val = matrix[r][num_buttons]
            if val < -1e-9 or abs(val - round(val)) > 1e-9:
                return 0

            rounded_val = round(val)
            if rounded_val < 0:
                return 0

            solution[pivot[r]] = rounded_val

        return sum(solution)

    # Use recursive search with pruning for free variables
    current_solution = [0] * num_buttons
    max_free_value = max(targets)

    def search_solutions(free_var_idx):
        nonlocal min_presses

        if free_var_idx == len(free_vars):
            # Back-substitute for pivot variables
            test_solution = current_solution[:]
            valid = True

            for r in range(num_counters - 1, -1, -1):
                if pivot[r] == -1:
                    continue

                pivot_col = pivot[r]
                val = matrix[r][num_buttons]
                for c in range(pivot_col + 1, num_buttons):
                    if abs(matrix[r][c]) > 1e-9:
                        val -= matrix[r][c] * test_solution[c]

                if val < -1e-9 or abs(val - round(val)) > 1e-9:
                    valid = False
                    break

                rounded_val = round(val)
                if rounded_val < 0:
                    valid = False
                    break

                test_solution[pivot_col] = rounded_val

            if valid:
                presses = sum(test_solution)
                min_presses = min(min_presses, presses)
            return

        # Try values for this free variable
        var_idx = free_vars[free_var_idx]
        current_sum = sum(current_solution)
        upper_bound = min(max_free_value, min_presses - current_sum)

        for value in range(int(upper_bound) + 1):
            current_solution[var_idx] = value
            search_solutions(free_var_idx + 1)

            # Early exit if found perfect solution
            if min_presses == 0:
                return

        current_solution[var_idx] = 0

    search_solutions(0)
    return min_presses if min_presses != float('inf') else 0


def run():
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day10_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day10.txt")

    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=7)
    run_solution("Part 2", part2, test_input_path, real_input_path, expected_test_result=33)
