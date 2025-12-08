import os
from utils.input_reader import run_solution

def solve_part1(line: str) -> int:
    digits = [int(c) for c in line.strip()]
    max_joltage = -1
    n = len(digits)
    
    for i in range(n):
        for j in range(i + 1, n):
            joltage = digits[i] * 10 + digits[j]
            if joltage > max_joltage:
                max_joltage = joltage
                
    return max_joltage if max_joltage != -1 else 0

def solve_part2(line: str) -> int:
    digits = [int(c) for c in line.strip()]
    k = 12
    stack = []
    n = len(digits)
    
    for i in range(n):
        digit = digits[i]
        remaining = n - 1 - i
        
        while stack and digit > stack[-1] and len(stack) + remaining >= k:
            stack.pop()
            
        if len(stack) < k:
            stack.append(digit)
            
    if not stack:
        return 0
        
    # Convert stack to number
    return int("".join(map(str, stack)))

def part1(input_text: str) -> int:
    input_text = input_text.replace("\r", "").strip()
    if not input_text:
        return 0
        
    lines = input_text.split('\n')
    total_output_joltage = 0
    
    for line in lines:
        if not line.strip():
            continue
        total_output_joltage += solve_part1(line)
        
    return total_output_joltage

def part2(input_text: str) -> int:
    input_text = input_text.replace("\r", "").strip()
    if not input_text:
        return 0
        
    lines = input_text.split('\n')
    total_output_joltage = 0
    
    for line in lines:
        if not line.strip():
            continue
        total_output_joltage += solve_part2(line)
        
    return total_output_joltage

def run():
    # Go up two levels to reach solution root, then into inputs
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day03_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day03.txt")
    
    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=357)
    run_solution("Part 2", part2, test_input_path, real_input_path, expected_test_result=3121910778619)
