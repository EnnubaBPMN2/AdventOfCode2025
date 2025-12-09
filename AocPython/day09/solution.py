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
            
            rect_min_x = min(tile1[0], tile2[0])
            rect_max_x = max(tile1[0], tile2[0])
            rect_min_y = min(tile1[1], tile2[1])
            rect_max_y = max(tile1[1], tile2[1])
            
            # Check if all four corners are inside or on the polygon boundary
            if not is_inside_or_on_boundary((rect_min_x, rect_min_y), red_tiles):
                continue
            if not is_inside_or_on_boundary((rect_min_x, rect_max_y), red_tiles):
                continue
            if not is_inside_or_on_boundary((rect_max_x, rect_min_y), red_tiles):
                continue
            if not is_inside_or_on_boundary((rect_max_x, rect_max_y), red_tiles):
                continue
            
            # Check if any red tile is strictly inside the rectangle
            has_interior_tile = False
            for tile in red_tiles:
                if (tile[0] > rect_min_x and tile[0] < rect_max_x and 
                    tile[1] > rect_min_y and tile[1] < rect_max_y):
                    has_interior_tile = True
                    break
            
            if has_interior_tile:
                continue
            
            # Check if any polygon edge properly crosses the rectangle boundary
            has_crossing = False
            for k in range(len(red_tiles)):
                p1 = red_tiles[k]
                p2 = red_tiles[(k + 1) % len(red_tiles)]
                
                # Check if edge crosses any rectangle side
                if (segments_properly_intersect(p1, p2, (rect_min_x, rect_min_y), (rect_max_x, rect_min_y)) or
                    segments_properly_intersect(p1, p2, (rect_min_x, rect_max_y), (rect_max_x, rect_max_y)) or
                    segments_properly_intersect(p1, p2, (rect_min_x, rect_min_y), (rect_min_x, rect_max_y)) or
                    segments_properly_intersect(p1, p2, (rect_max_x, rect_min_y), (rect_max_x, rect_max_y))):
                    has_crossing = True
                    break
            
            if not has_crossing:
                width = rect_max_x - rect_min_x + 1
                height = rect_max_y - rect_min_y + 1
                area = width * height
                max_area = max(max_area, area)
    
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
