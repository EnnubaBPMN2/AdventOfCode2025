import os
from utils.input_reader import run_solution


def part1(input_text: str) -> int:
    """
    Find the largest rectangle area using any two red tiles as opposite corners.
    """
    lines = input_text.strip().split('\n')
    if not lines:
        return 0
    
    # Parse red tile coordinates
    red_tiles = []
    for line in lines:
        parts = line.split(',')
        if len(parts) == 2:
            x = int(parts[0].strip())
            y = int(parts[1].strip())
            red_tiles.append((x, y))
    
    if len(red_tiles) < 2:
        return 0
    
    max_area = 0
    
    # Try all pairs of red tiles as opposite corners
    for i in range(len(red_tiles)):
        for j in range(i + 1, len(red_tiles)):
            tile1 = red_tiles[i]
            tile2 = red_tiles[j]
            
            # Calculate rectangle area
            width = abs(tile2[0] - tile1[0]) + 1
            height = abs(tile2[1] - tile1[1]) + 1
            area = width * height
            
            max_area = max(max_area, area)
    
    return max_area


def part2(input_text: str) -> int:
    """
    Find the largest rectangle area using red tiles as corners,
    where all tiles in the rectangle are red or green (inside the polygon).
    HIGHLY OPTIMIZED VERSION: Aggressive inlining and loop reduction.
    """
    lines = input_text.strip().split('\n')
    if not lines:
        return 0

    # Parse red tile coordinates as list for fastest iteration
    red_tiles = []
    for line in lines:
        parts = line.split(',')
        if len(parts) == 2:
            x = int(parts[0].strip())
            y = int(parts[1].strip())
            red_tiles.append((x, y))

    n = len(red_tiles)
    if n < 2:
        return 0

    max_area = 0

    # Try all pairs of red tiles as opposite corners
    for i in range(n):
        x1, y1 = red_tiles[i]

        for j in range(i + 1, n):
            x2, y2 = red_tiles[j]

            rect_min_x = min(x1, x2)
            rect_max_x = max(x1, x2)
            rect_min_y = min(y1, y2)
            rect_max_y = max(y1, y2)

            # Quick reject: Check if any tile is strictly inside
            has_interior = False
            for tx, ty in red_tiles:
                if rect_min_x < tx < rect_max_x and rect_min_y < ty < rect_max_y:
                    has_interior = True
                    break
            if has_interior:
                continue

            # Check all 4 corners are inside or on boundary
            corners_valid = True
            for cx, cy in [(rect_min_x, rect_min_y), (rect_min_x, rect_max_y),
                          (rect_max_x, rect_min_y), (rect_max_x, rect_max_y)]:

                on_boundary = False
                # Check if corner is on any edge
                for k in range(n):
                    p1x, p1y = red_tiles[k]
                    p2x, p2y = red_tiles[(k + 1) % n]

                    # Vertical edge check
                    if p1x == p2x == cx:
                        if min(p1y, p2y) <= cy <= max(p1y, p2y):
                            on_boundary = True
                            break
                    # Horizontal edge check
                    elif p1y == p2y == cy:
                        if min(p1x, p2x) <= cx <= max(p1x, p2x):
                            on_boundary = True
                            break

                if not on_boundary:
                    # Ray casting for interior check
                    intersections = 0
                    for k in range(n):
                        p1x, p1y = red_tiles[k]
                        p2x, p2y = red_tiles[(k + 1) % n]

                        if (p1y > cy) != (p2y > cy):
                            intersect_x = (p2x - p1x) * (cy - p1y) / (p2y - p1y) + p1x
                            if cx < intersect_x:
                                intersections += 1

                    if (intersections % 2) == 0:
                        corners_valid = False
                        break

            if not corners_valid:
                continue

            # Check polygon edges don't cross rectangle
            has_crossing = False
            for k in range(n):
                if has_crossing:
                    break

                p1x, p1y = red_tiles[k]
                p2x, p2y = red_tiles[(k + 1) % n]

                # Check against all 4 rectangle edges
                # Bottom edge
                val1 = (p1y - rect_min_y) * (rect_max_x - rect_min_x)
                d1 = 0 if val1 == 0 else (1 if val1 > 0 else -1)
                val2 = (p2y - rect_min_y) * (rect_max_x - rect_min_x)
                d2 = 0 if val2 == 0 else (1 if val2 > 0 else -1)
                val3 = (rect_min_y - p1y) * (p2x - p1x) - (p2y - p1y) * (rect_min_x - p1x)
                d3 = 0 if val3 == 0 else (1 if val3 > 0 else -1)
                val4 = (rect_min_y - p1y) * (p2x - p1x) - (p2y - p1y) * (rect_max_x - p1x)
                d4 = 0 if val4 == 0 else (1 if val4 > 0 else -1)
                if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
                    has_crossing = True
                    break

                # Top edge
                val1 = (p1y - rect_max_y) * (rect_max_x - rect_min_x)
                d1 = 0 if val1 == 0 else (1 if val1 > 0 else -1)
                val2 = (p2y - rect_max_y) * (rect_max_x - rect_min_x)
                d2 = 0 if val2 == 0 else (1 if val2 > 0 else -1)
                val3 = (rect_max_y - p1y) * (p2x - p1x) - (p2y - p1y) * (rect_min_x - p1x)
                d3 = 0 if val3 == 0 else (1 if val3 > 0 else -1)
                val4 = (rect_max_y - p1y) * (p2x - p1x) - (p2y - p1y) * (rect_max_x - p1x)
                d4 = 0 if val4 == 0 else (1 if val4 > 0 else -1)
                if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
                    has_crossing = True
                    break

                # Left edge
                val1 = (p1x - rect_min_x) * (rect_max_y - rect_min_y)
                d1 = 0 if val1 == 0 else (1 if val1 > 0 else -1)
                val2 = (p2x - rect_min_x) * (rect_max_y - rect_min_y)
                d2 = 0 if val2 == 0 else (1 if val2 > 0 else -1)
                val3 = (rect_min_y - p1y) * (p2x - p1x) - (p2y - p1y) * (rect_min_x - p1x)
                d3 = 0 if val3 == 0 else (1 if val3 > 0 else -1)
                val4 = (rect_max_y - p1y) * (p2x - p1x) - (p2y - p1y) * (rect_min_x - p1x)
                d4 = 0 if val4 == 0 else (1 if val4 > 0 else -1)
                if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
                    has_crossing = True
                    break

                # Right edge
                val1 = (p1x - rect_max_x) * (rect_max_y - rect_min_y)
                d1 = 0 if val1 == 0 else (1 if val1 > 0 else -1)
                val2 = (p2x - rect_max_x) * (rect_max_y - rect_min_y)
                d2 = 0 if val2 == 0 else (1 if val2 > 0 else -1)
                val3 = (rect_min_y - p1y) * (p2x - p1x) - (p2y - p1y) * (rect_max_x - p1x)
                d3 = 0 if val3 == 0 else (1 if val3 > 0 else -1)
                val4 = (rect_max_y - p1y) * (p2x - p1x) - (p2y - p1y) * (rect_max_x - p1x)
                d4 = 0 if val4 == 0 else (1 if val4 > 0 else -1)
                if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
                    has_crossing = True
                    break

            if not has_crossing:
                area = (rect_max_x - rect_min_x + 1) * (rect_max_y - rect_min_y + 1)
                if area > max_area:
                    max_area = area

    return max_area


def is_inside_or_on_boundary(point, polygon):
    """Check if a point is inside or on the boundary of the polygon."""
    # Check if on boundary first
    for i in range(len(polygon)):
        p1 = polygon[i]
        p2 = polygon[(i + 1) % len(polygon)]
        
        if is_point_on_segment(point, p1, p2):
            return True
    
    # Use ray casting for interior check
    return is_inside_polygon(point, polygon)


def is_point_on_segment(point, p1, p2):
    """Check if a point is on the line segment p1-p2."""
    if p1[0] == p2[0] == point[0]:
        min_y = min(p1[1], p2[1])
        max_y = max(p1[1], p2[1])
        return min_y <= point[1] <= max_y
    
    if p1[1] == p2[1] == point[1]:
        min_x = min(p1[0], p2[0])
        max_x = max(p1[0], p2[0])
        return min_x <= point[0] <= max_x
    
    return False


def is_inside_polygon(point, polygon):
    """Ray casting algorithm to determine if point is inside polygon."""
    intersections = 0
    n = len(polygon)
    
    for i in range(n):
        p1 = polygon[i]
        p2 = polygon[(i + 1) % n]
        
        if (p1[1] > point[1]) != (p2[1] > point[1]):
            intersect_x = (p2[0] - p1[0]) * (point[1] - p1[1]) / (p2[1] - p1[1]) + p1[0]
            if point[0] < intersect_x:
                intersections += 1
    
    return (intersections % 2) == 1


def segments_properly_intersect(p1, p2, p3, p4):
    """Check if segments p1-p2 and p3-p4 properly intersect (cross each other)."""
    d1 = direction(p3, p4, p1)
    d2 = direction(p3, p4, p2)
    d3 = direction(p1, p2, p3)
    d4 = direction(p1, p2, p4)
    
    if ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and \
       ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0)):
        return True
    
    return False


def direction(p1, p2, p3):
    """Cross product to determine orientation."""
    val = (p3[1] - p1[1]) * (p2[0] - p1[0]) - (p2[1] - p1[1]) * (p3[0] - p1[0])
    if val == 0:
        return 0  # collinear
    return 1 if val > 0 else -1  # clockwise or counterclockwise


def run():
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day09_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day09.txt")
    
    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=50)
    run_solution("Part 2", part2, test_input_path, real_input_path, expected_test_result=24)
