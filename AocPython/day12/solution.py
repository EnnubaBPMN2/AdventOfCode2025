import os
from utils.input_reader import run_solution


class Shape:
    """Optimized shape representation matching C# implementation exactly."""
    __slots__ = ('rows', 'cols', 'cell_count', 'width', 'height', 'area')

    def __init__(self, shape_lines):
        """Parse shape and precompute all necessary data."""
        # Collect cells first
        cells = []
        for r, line in enumerate(shape_lines):
            for c, cell in enumerate(line):
                if cell == '#':
                    cells.append((r, c))

        # Store as separate arrays like C#
        self.cell_count = len(cells)
        self.rows = [0] * self.cell_count
        self.cols = [0] * self.cell_count

        for i, (r, c) in enumerate(cells):
            self.rows[i] = r
            self.cols[i] = c

        self.height = len(shape_lines)
        self.width = max(len(line) for line in shape_lines) if shape_lines else 0
        self.area = self.cell_count


def part1(input_text: str) -> int:
    """
    Christmas Tree Farm - Part 1
    Count how many regions can fit all their required presents.
    """
    shapes, regions = parse_input(input_text)

    # Precompute all shape orientations once
    all_orientations = [get_all_orientations(shape) for shape in shapes]

    count = 0
    for region in regions:
        if can_fit_all_presents(region, all_orientations):
            count += 1

    return count


def parse_input(input_text: str):
    """Parse the input into shapes and regions."""
    lines = input_text.replace('\r', '').split('\n')
    shapes = []
    regions = []

    i = 0
    while i < len(lines):
        line = lines[i]

        # Parse region (check this first since it also contains ':')
        if 'x' in line and ':' in line:
            parts = line.split(':')
            dimensions = parts[0].strip().split('x')
            width = int(dimensions[0])
            height = int(dimensions[1])

            counts = list(map(int, parts[1].strip().split()))
            regions.append((width, height, counts))
            i += 1
        # Parse shape
        elif ':' in line:
            shape_lines = []
            i += 1  # Skip the label line

            while i < len(lines) and lines[i].strip() and ':' not in lines[i]:
                shape_lines.append(lines[i])
                i += 1

            if shape_lines:
                shapes.append(shape_lines)
        else:
            i += 1

    return shapes, regions


def can_fit_all_presents(region, all_orientations):
    """Check if all required presents can fit in the region."""
    width, height, counts = region

    # Quick area check
    total_area = width * height
    required_area = 0

    for i, count in enumerate(counts):
        if count > 0:
            required_area += all_orientations[i][0].area * count

    if required_area > total_area:
        return False

    # Use list of False for grid - simpler than bytearray
    grid = [False] * (width * height)
    counts_mutable = counts[:]

    return try_place_presents(grid, width, height, counts_mutable, all_orientations, 0)


def try_place_presents(grid, width, height, counts, all_orientations, call_count):
    """Recursively try to place all presents using backtracking."""
    if call_count > 2000000:
        return False

    # Check if all presents are placed - match C# logic exactly
    all_placed = True
    for i in range(len(counts)):
        if counts[i] > 0:
            all_placed = False
            break
    if all_placed:
        return True

    # Try placing first available present type
    for shape_idx in range(len(counts)):
        if counts[shape_idx] == 0:
            continue

        orientations = all_orientations[shape_idx]

        # Try each orientation at each position
        for shape in orientations:
            # Match C# loop structure exactly
            for row in range(height - shape.height + 1):
                for col in range(width - shape.width + 1):
                    # Inline can_place_shape - match C# exactly
                    can_place = True
                    for i in range(shape.cell_count):
                        grid_idx = (row + shape.rows[i]) * width + (col + shape.cols[i])
                        if grid[grid_idx]:
                            can_place = False
                            break

                    if can_place:
                        # Place shape - match C# exactly
                        for i in range(shape.cell_count):
                            grid_idx = (row + shape.rows[i]) * width + (col + shape.cols[i])
                            grid[grid_idx] = True

                        counts[shape_idx] -= 1

                        if try_place_presents(grid, width, height, counts, all_orientations, call_count + 1):
                            return True

                        # Remove shape - match C# exactly
                        for i in range(shape.cell_count):
                            grid_idx = (row + shape.rows[i]) * width + (col + shape.cols[i])
                            grid[grid_idx] = False

                        counts[shape_idx] += 1

        # If we couldn't place this present type anywhere, fail
        return False

    return True


def get_all_orientations(shape_template):
    """Get all unique orientations (rotations and flips) of a shape."""
    orientations = set()
    current = shape_template

    for _ in range(4):
        orientations.add(tuple(current))

        # Also add flipped version
        flipped = flip(current)
        orientations.add(tuple(flipped))

        current = rotate(current)

    # Convert to Shape objects
    return [Shape(list(o)) for o in orientations]


def rotate(shape):
    """Rotate shape 90 degrees clockwise."""
    rows = len(shape)
    cols = len(shape[0])
    rotated = []

    for c in range(cols):
        new_row = ''.join(shape[rows - 1 - r][c] for r in range(rows))
        rotated.append(new_row)

    return rotated


def flip(shape):
    """Flip shape horizontally."""
    return [row[::-1] for row in shape]


def run():
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day12_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day12.txt")

    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=2)
    print("\n🎄 Part 2 automatically completed! Both stars earned! 🎄\n")
