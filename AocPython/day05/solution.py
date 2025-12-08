import os
from utils.input_reader import run_solution

def solve_part1(input_text: str) -> int:
    sections = input_text.strip().split("\n\n")
    if len(sections) < 2:
        return 0
        
    range_lines = sections[0].splitlines()
    id_lines = sections[1].splitlines()
    
    ranges = []
    for line in range_lines:
        parts = line.split('-')
        if len(parts) == 2:
            try:
                start, end = int(parts[0]), int(parts[1])
                ranges.append((start, end))
            except ValueError:
                continue
                
    ids = []
    for line in id_lines:
        try:
            ids.append(int(line))
        except ValueError:
            continue
            
    fresh_count = 0
    for id_val in ids:
        is_fresh = False
        for start, end in ranges:
            if start <= id_val <= end:
                is_fresh = True
                break
        
        if is_fresh:
            fresh_count += 1
            
    return fresh_count

def solve_part2(input_text: str) -> int:
    sections = input_text.strip().split("\n\n")
    if len(sections) < 1:
        return 0
        
    range_lines = sections[0].splitlines()
    
    ranges = []
    for line in range_lines:
        parts = line.split('-')
        if len(parts) == 2:
            try:
                start, end = int(parts[0]), int(parts[1])
                ranges.append([start, end])
            except ValueError:
                continue
    
    # Sort ranges by start
    ranges.sort(key=lambda x: x[0])
    
    merged_ranges = []
    if ranges:
        current_range = ranges[0]
        for i in range(1, len(ranges)):
            next_range = ranges[i]
            # Check for overlap or adjacency
            if next_range[0] <= current_range[1] + 1:
                current_range[1] = max(current_range[1], next_range[1])
            else:
                merged_ranges.append(current_range)
                current_range = next_range
        merged_ranges.append(current_range)
        
    total_fresh = 0
    for start, end in merged_ranges:
        total_fresh += (end - start + 1)
        
    return total_fresh

def part1(input_text: str) -> int:
    return solve_part1(input_text)

def part2(input_text: str) -> int:
    return solve_part2(input_text)

def run():
    # Go up two levels to reach solution root, then into inputs
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day05_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day05.txt")
    
    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=3)
    run_solution("Part 2", part2, test_input_path, real_input_path, expected_test_result=14)
