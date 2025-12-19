import os
from utils.input_reader import run_solution


class Shape:
    """Optimized shape representation with precomputed cell positions."""
    __slots__ = ('cells', 'width', 'height', 'area', 'cell_count')

    def __init__(self, shape_lines):
        """Parse shape and precompute all necessary data."""
        # Store as tuple of tuples for immutability and speed
        cells = []
        for r, line in enumerate(shape_lines):
            for c, cell in enumerate(line):
                if cell == '#':
                    cells.append((r, c))

        self.cells = tuple(cells)  # Immutable tuple is faster
        self.cell_count = len(cells)
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
    all_orientations = tuple(tuple(get_all_orientations(shape)) for shape in shapes)

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

            counts = tuple(map(int, parts[1].strip().split()))
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
    required_area = sum(
        all_orientations[i][0].area * count
        for i, count in enumerate(counts) if count > 0
    )

    if required_area > total_area:
        return False

    # Use bytearray for grid - much faster than list for boolean operations
    grid = bytearray(width * height)
    counts_list = list(counts)

    return try_place_presents(grid, width, height, counts_list, all_orientations, 0)


def try_place_presents(grid, width, height, counts, all_orientations, call_count):
    """Recursively try to place all presents using backtracking."""
    if call_count > 2000000:
        return False

    # Check if all presents are placed - cache len for speed
    counts_len = len(counts)
    for i in range(counts_len):
        if counts[i] > 0:
            break
    else:
        return True  # All counts are 0

    # Try placing first available present type
    for shape_idx in range(counts_len):
        count = counts[shape_idx]
        if count == 0:
            continue

        orientations = all_orientations[shape_idx]

        # Try each orientation at each position
        for shape in orientations:
            # Cache shape attributes to avoid repeated lookups
            shape_height = shape.height
            shape_width = shape.width
            shape_cells = shape.cells
            shape_cell_count = shape.cell_count

            max_row = height - shape_height
            max_col = width - shape_width

            for row in range(max_row + 1):
                for col in range(max_col + 1):
                    # Inline can_place_shape for speed
                    can_place = True
                    for i in range(shape_cell_count):
                        r, c = shape_cells[i]
                        grid_idx = (row + r) * width + (col + c)
                        if grid[grid_idx]:
                            can_place = False
                            break

                    if can_place:
                        # Place shape
                        for i in range(shape_cell_count):
                            r, c = shape_cells[i]
                            grid[(row + r) * width + (col + c)] = 1

                        counts[shape_idx] -= 1

                        if try_place_presents(grid, width, height, counts, all_orientations, call_count + 1):
                            return True

                        # Backtrack - remove shape
                        for i in range(shape_cell_count):
                            r, c = shape_cells[i]
                            grid[(row + r) * width + (col + c)] = 0

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
