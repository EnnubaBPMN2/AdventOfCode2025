"""
Advent of Code 2025 - Day 01: Secret Entrance
"""

import os
from utils.input_reader import run_solution

def part1(input_text: str) -> int:
    """
    Count how many times the dial points at 0 after rotations
    
    Args:
        input_text: Space-separated rotation instructions (e.g., "L68 R30")
        
    Returns:
        Number of times the dial points at 0
    """
    rotations = input_text.split()
    
    position = 50  # Starting position
    zero_count = 0
    
    for rotation in rotations:
        direction = rotation[0]
        distance = int(rotation[1:])
        
        if direction == 'L':
            position = (position - distance) % 100
        elif direction == 'R':
            position = (position + distance) % 100
        
        if position == 0:
            zero_count += 1
    
    return zero_count

def part2(input_text: str) -> int:
    """
    Part 2: Count number of times dial points at 0 during rotations
    
    Args:
        input_text: Puzzle input
        
    Returns:
        Solution for part 2
    """
    rotations = input_text.split()
    
    position = 50  # Starting position
    zero_count = 0
    
    for rotation in rotations:
        direction = rotation[0]
        distance = int(rotation[1:])
        
        if direction == 'R':
            # Moving right: count multiples of 100 in range (position, position + distance]
            zero_count += (position + distance) // 100
            position = (position + distance) % 100
            
        elif direction == 'L':
            # Moving left: count multiples of 100 in range [position - distance, position)
            # Count = floor((pos - 1) / 100) - floor((pos - dist - 1) / 100)
            
            start_floor = -1 if (position - 1) < 0 else 0
            end_floor = (position - distance - 1) // 100
            
            zero_count += start_floor - end_floor
            
            position = (position - distance) % 100
            
    return zero_count

def run():
    """Run Day 01 solutions"""
    print("\n" + "="*50)
    print("    Advent of Code 2025 - Day 01")
    print("         Secret Entrance")
    print("="*50)
    
    # Get the directory where this file is located
    day_dir = os.path.dirname(os.path.abspath(__file__))
    # Go up two levels to reach solution root, then into inputs
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day01_test.txt")
    input_path = os.path.join(solution_root, "inputs", "day01.txt")
    
    # Part 1
    run_solution(
        "Part 1",
        part1,
        test_input_path,
        input_path,
        expected_test_result=3
    )
    
    # Part 2
    run_solution(
        "Part 2",
        part2,
        test_input_path,
        input_path,
        expected_test_result=6
    )
