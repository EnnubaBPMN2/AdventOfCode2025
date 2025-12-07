# Quick test script for Day 01 Part 1
from day01.solution import part1

test_input = "L68 L30 R48 L5 R60 L55 L1 L99 R14 L82"
result = part1(test_input)

print(f"Day 01 Part 1 Test Result: {result}")
print(f"Expected: 3")
print(f"Test {'PASSED ✓' if result == 3 else 'FAILED ✗'}")
