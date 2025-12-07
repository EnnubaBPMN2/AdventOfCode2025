"""Input reading utilities for Advent of Code solutions"""

import os
from pathlib import Path

def read_input(file_path: str) -> str:
    """
    Reads the entire content of a file as a single string
    
    Args:
        file_path: Path to the input file
        
    Returns:
        File content as a string, stripped of leading/trailing whitespace
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Input file not found: {file_path}")
    
    with open(file_path, 'r') as f:
        return f.read().strip()

def read_lines(file_path: str) -> list[str]:
    """
    Reads a file and returns a list of non-empty lines
    
    Args:
        file_path: Path to the input file
        
    Returns:
        List of non-empty lines
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Input file not found: {file_path}")
    
    with open(file_path, 'r') as f:
        return [line.strip() for line in f if line.strip()]

def read_split(file_path: str, delimiter: str = ',') -> list[str]:
    """
    Reads a file and splits content by a delimiter
    
    Args:
        file_path: Path to the input file
        delimiter: Character to split on (default: comma)
        
    Returns:
        List of split values
    """
    content = read_input(file_path)
    return [item.strip() for item in content.split(delimiter) if item.strip()]

def run_test(test_name: str, test_func, expected):
    """
    Runs a test case and compares the result with expected value
    
    Args:
        test_name: Name of the test
        test_func: Function to execute (should take no arguments)
        expected: Expected result
        
    Returns:
        True if test passed, False otherwise
    """
    print(f"Running {test_name}... ", end='')
    
    try:
        result = test_func()
        passed = result == expected
        
        if passed:
            print(f"✓ PASSED (Result: {result})")
        else:
            print(f"✗ FAILED (Expected: {expected}, Got: {result})")
        
        return passed
    except Exception as e:
        print(f"✗ ERROR: {e}")
        return False

def run_solution(part_name: str, solver, test_input_path: str, real_input_path: str, expected_test_result=None):
    """
    Runs a solution part with both test and real inputs
    
    Args:
        part_name: Name of the part (e.g., "Part 1")
        solver: Function that takes input string and returns result
        test_input_path: Path to test input file
        real_input_path: Path to real input file
        expected_test_result: Expected result for test input (optional)
    """
    print(f"\n=== {part_name} ===")
    
    # Run test if expected result is provided
    if expected_test_result is not None:
        if os.path.exists(test_input_path):
            test_input = read_input(test_input_path)
            run_test(f"{part_name} (Test)", lambda: solver(test_input), expected_test_result)
    
    # Run with real input
    if os.path.exists(real_input_path):
        real_input = read_input(real_input_path)
        print(f"Running {part_name} (Real Input)... ", end='')
        
        try:
            result = solver(real_input)
            print(f"Result: {result}")
        except Exception as e:
            print(f"ERROR: {e}")
    else:
        print(f"⚠ Real input file not found: {real_input_path}")
        print("  Please download your puzzle input from https://adventofcode.com/2025/day/X/input")
