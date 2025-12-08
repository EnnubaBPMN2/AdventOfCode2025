import os
from utils.input_reader import run_solution

def solve(input_text: str, part2: bool = False) -> int:
    lines = [list(line.strip()) for line in input_text.split('\n') if line.strip()]
    if not lines:
        return 0
        
    rows = len(lines)
    cols = len(lines[0])
    
    # Directions: N, NE, E, SE, S, SW, W, NW
    dr = [-1, -1, 0, 1, 1, 1, 0, -1]
    dc = [0, 1, 1, 1, 0, -1, -1, -1]
    
    total_removed = 0
    
    while True:
        to_remove = []
        
        for r in range(rows):
            for c in range(cols):
                if lines[r][c] == '@':
                    neighbor_count = 0
                    for i in range(8):
                        nr, nc = r + dr[i], c + dc[i]
                        if 0 <= nr < rows and 0 <= nc < cols and lines[nr][nc] == '@':
                            neighbor_count += 1
                            
                    if neighbor_count < 4:
                        to_remove.append((r, c))
        
        if not to_remove:
            break
            
        if not part2:
            return len(to_remove)
            
        total_removed += len(to_remove)
        for r, c in to_remove:
            lines[r][c] = '.'
            
    return total_removed

def part1(input_text: str) -> int:
    return solve(input_text, part2=False)

def part2(input_text: str) -> int:
    return solve(input_text, part2=True)

def run():
    # Go up two levels to reach solution root, then into inputs
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day04_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day04.txt")
    
    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=13)
    run_solution("Part 2", part2, test_input_path, real_input_path, expected_test_result=43)
