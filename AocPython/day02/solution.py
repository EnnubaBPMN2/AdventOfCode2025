import os
from utils.input_reader import run_solution

def is_invalid_id_part1(n: int) -> bool:
    s = str(n)
    if len(s) % 2 != 0:
        return False
    
    half = len(s) // 2
    first_half = s[:half]
    second_half = s[half:]
    
    return first_half == second_half

def is_invalid_id_part2(n: int) -> bool:
    s = str(n)
    length = len(s)
    
    # Try all possible pattern lengths L
    # The pattern must repeat at least twice, so L can go up to length // 2
    for L in range(1, (length // 2) + 1):
        if length % L == 0:
            k = length // L  # Number of repetitions
            # k is guaranteed to be >= 2 because L <= length // 2
            
            pattern = s[:L]
            
            # Check if s is composed of k repetitions of pattern
            # We can construct the expected string and compare
            if pattern * k == s:
                return True
                
    return False

def solve(input_text: str, validator) -> int:
    # Input format: "11-22,95-115,..."
    input_text = input_text.replace("\r", "").replace("\n", "").strip()
    if not input_text:
        return 0
        
    ranges = input_text.split(',')
    total_invalid_sum = 0
    
    for r in ranges:
        parts = r.split('-')
        if len(parts) != 2:
            continue
            
        try:
            min_val = int(parts[0])
            max_val = int(parts[1])
            
            for i in range(min_val, max_val + 1):
                if validator(i):
                    total_invalid_sum += i
        except ValueError:
            continue
            
    return total_invalid_sum

def part1(input_text: str) -> int:
    return solve(input_text, is_invalid_id_part1)

def part2(input_text: str) -> int:
    return solve(input_text, is_invalid_id_part2)

def run():
    # Go up two levels to reach solution root, then into inputs
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day02_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day02.txt")
    
    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=1227775554)
    run_solution("Part 2", part2, test_input_path, real_input_path, expected_test_result=4174379265)
