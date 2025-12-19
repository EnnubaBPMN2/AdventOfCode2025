import os
from utils.input_reader import run_solution


def part1(input_text: str) -> int:
    """
    Christmas Tree Farm - Part 1
    Count how many regions can fit all their required presents.
    """
    shapes, regions = parse_input(input_text)

    count = 0
    for region in regions:
        if can_fit_all_presents(region, shapes):
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


def can_fit_all_presents(region, shape_templates):
    """Check if all required presents can fit in the region."""
    width, height, counts = region

    # Quick area check - if total shape area exceeds grid area, impossible
    total_area = width * height
    required_area = 0

    for i, count in enumerate(counts):
        if count > 0:
            shape_area = get_shape_area(shape_templates[i])
            required_area += shape_area * count

    if required_area > total_area:
        return False

    # Initialize grid
    grid = [['.' for _ in range(width)] for _ in range(height)]

    # Build list of presents to place
    presents = []
    for i, count in enumerate(counts):
        if count > 0:
            presents.append([i, count])  # Use list for in-place modification

    # Pre-compute all orientations for all shapes (major optimization)
    all_orientations = [get_all_orientations(shape_templates[i]) for i in range(len(shape_templates))]

    # Pre-compute shape widths for bounds checking (major optimization)
    shape_widths = {}
    for shape_idx, orientations in enumerate(all_orientations):
        for orient_idx, shape in enumerate(orientations):
            shape_widths[(shape_idx, orient_idx)] = max(len(row) for row in shape) if shape else 0

    # Try to place all presents
    call_count = [0]
    return try_place_presents(grid, presents, all_orientations, shape_widths, ord('A'), call_count)


def get_shape_area(shape):
    """Calculate the area of a shape (number of '#' cells)."""
    area = 0
    for row in shape:
        area += row.count('#')
    return area


def try_place_presents(grid, presents, all_orientations, shape_widths, label_ord, call_count):
    """Recursively try to place all presents using backtracking."""
    call_count[0] += 1
    if call_count[0] > 2000000:
        return False  # Fail faster on impossible regions

    # Check if all presents are placed (faster without all())
    all_placed = True
    for i in range(len(presents)):
        if presents[i][1] > 0:
            all_placed = False
            break
    if all_placed:
        return True

    grid_height = len(grid)
    grid_width = len(grid[0])

    # Try placing first available present type
    for i in range(len(presents)):
        shape_index, count = presents[i]
        if count == 0:
            continue

        shapes = all_orientations[shape_index]

        for orient_idx, shape in enumerate(shapes):
            max_width = shape_widths[(shape_index, orient_idx)]
            shape_height = len(shape)

            # Try placing at every position with early bounds checks
            for row in range(grid_height - shape_height + 1):
                for col in range(grid_width - max_width + 1):
                    if can_place_shape_fast(grid, shape, row, col):
                        place_shape(grid, shape, row, col, chr(label_ord))

                        # Modify in place (faster than creating new list)
                        presents[i][1] -= 1

                        if try_place_presents(grid, presents, all_orientations, shape_widths, label_ord + 1, call_count):
                            return True

                        # Backtrack
                        presents[i][1] += 1
                        remove_shape(grid, shape, row, col)

        # If we couldn't place this present type anywhere, fail
        return False

    return True  # All presents placed


def get_all_orientations(shape):
    """Get all unique orientations (rotations and flips) of a shape."""
    orientations = set()
    current = shape

    for _ in range(4):
        orientations.add(tuple(current))

        # Also add flipped version
        flipped = flip(current)
        orientations.add(tuple(flipped))

        current = rotate(current)

    return [list(o) for o in orientations]


def rotate(shape):
    """Rotate shape 90 degrees clockwise."""
    rows = len(shape)
    cols = len(shape[0])
    rotated = []

    for c in range(cols):
        new_row = ''
        for r in range(rows):
            new_row += shape[rows - 1 - r][c]
        rotated.append(new_row)

    return rotated


def flip(shape):
    """Flip shape horizontally."""
    return [row[::-1] for row in shape]


def can_place_shape_fast(grid, shape, start_row, start_col):
    """Check if a shape can be placed at the given position (optimized)."""
    # Bounds checking done in caller for performance
    for r in range(len(shape)):
        row_str = shape[r]
        grid_row = grid[start_row + r]
        for c in range(len(row_str)):
            if row_str[c] == '#':
                # Only check '#' cells - '.' cells in the shape can overlap anything
                if grid_row[start_col + c] != '.':
                    return False

    return True


def place_shape(grid, shape, start_row, start_col, label):
    """Place a shape on the grid."""
    for r, row in enumerate(shape):
        for c, cell in enumerate(row):
            if cell == '#':
                grid[start_row + r][start_col + c] = label


def remove_shape(grid, shape, start_row, start_col):
    """Remove a shape from the grid."""
    for r, row in enumerate(shape):
        for c, cell in enumerate(row):
            if cell == '#':
                grid[start_row + r][start_col + c] = '.'


def run():
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day12_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day12.txt")

    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=2)
    print("\n🎄 Part 2 automatically completed! Both stars earned! 🎄\n")
