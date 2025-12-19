import sys
import time
sys.path.insert(0, 'AocPython')

from day12.solution import part1

# Read test input
with open('inputs/day12_test.txt', 'r') as f:
    test_input = f.read()

# Test
start = time.time()
result = part1(test_input)
elapsed = time.time() - start

print(f"Test Result: {result} in {elapsed:.3f}s")

# Real input
with open('inputs/day12.txt', 'r') as f:
    real_input = f.read()

start = time.time()
result = part1(real_input)
elapsed = time.time() - start

print(f"Real Result: {result} in {elapsed:.3f}s")
