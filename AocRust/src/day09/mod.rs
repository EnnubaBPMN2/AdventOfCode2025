use std::cmp::{max, min};

pub fn part1(input: &str) -> i64 {
    let lines: Vec<&str> = input.trim().lines().collect();
    if lines.is_empty() {
        return 0;
    }

    // Parse red tile coordinates
    let mut red_tiles = Vec::new();
    for line in lines {
        let parts: Vec<&str> = line.split(',').collect();
        if parts.len() == 2 {
            if let (Ok(x), Ok(y)) = (parts[0].trim().parse::<i32>(), parts[1].trim().parse::<i32>()) {
                red_tiles.push((x, y));
            }
        }
    }

    if red_tiles.len() < 2 {
        return 0;
    }

    let mut max_area: i64 = 0;

    // Try all pairs of red tiles as opposite corners
    for i in 0..red_tiles.len() {
        for j in (i + 1)..red_tiles.len() {
            let tile1 = red_tiles[i];
            let tile2 = red_tiles[j];

            // Calculate rectangle area
            let width = (tile2.0 - tile1.0).abs() + 1;
            let height = (tile2.1 - tile1.1).abs() + 1;
            let area = (width as i64) * (height as i64);

            max_area = max(max_area, area);
        }
    }

    max_area
}

pub fn part2(input: &str) -> i64 {
    let lines: Vec<&str> = input.trim().lines().collect();
    if lines.is_empty() {
        return 0;
    }

    // Parse red tile coordinates
    let mut red_tiles = Vec::new();
    for line in lines {
        let parts: Vec<&str> = line.split(',').collect();
        if parts.len() == 2 {
            if let (Ok(x), Ok(y)) = (parts[0].trim().parse::<i32>(), parts[1].trim().parse::<i32>()) {
                red_tiles.push((x, y));
            }
        }
    }

    if red_tiles.len() < 2 {
        return 0;
    }

    let mut max_area: i64 = 0;

    // Try all pairs of red tiles as opposite corners
    for i in 0..red_tiles.len() {
        for j in (i + 1)..red_tiles.len() {
            let tile1 = red_tiles[i];
            let tile2 = red_tiles[j];

            let rect_min_x = min(tile1.0, tile2.0);
            let rect_max_x = max(tile1.0, tile2.0);
            let rect_min_y = min(tile1.1, tile2.1);
            let rect_max_y = max(tile1.1, tile2.1);

            // Check if all four corners are inside or on the polygon boundary
            if !is_inside_or_on_boundary((rect_min_x, rect_min_y), &red_tiles) {
                continue;
            }
            if !is_inside_or_on_boundary((rect_min_x, rect_max_y), &red_tiles) {
                continue;
            }
            if !is_inside_or_on_boundary((rect_max_x, rect_min_y), &red_tiles) {
                continue;
            }
            if !is_inside_or_on_boundary((rect_max_x, rect_max_y), &red_tiles) {
                continue;
            }

            // Check if any red tile is strictly inside the rectangle
            let has_interior_tile = red_tiles.iter().any(|&tile| {
                tile.0 > rect_min_x && tile.0 < rect_max_x && tile.1 > rect_min_y && tile.1 < rect_max_y
            });

            if has_interior_tile {
                continue;
            }

            // Check if any polygon edge properly crosses the rectangle boundary
            let mut has_crossing = false;
            for k in 0..red_tiles.len() {
                let p1 = red_tiles[k];
                let p2 = red_tiles[(k + 1) % red_tiles.len()];

                // Check if edge crosses any rectangle side
                if segments_properly_intersect(p1, p2, (rect_min_x, rect_min_y), (rect_max_x, rect_min_y))
                    || segments_properly_intersect(p1, p2, (rect_min_x, rect_max_y), (rect_max_x, rect_max_y))
                    || segments_properly_intersect(p1, p2, (rect_min_x, rect_min_y), (rect_min_x, rect_max_y))
                    || segments_properly_intersect(p1, p2, (rect_max_x, rect_min_y), (rect_max_x, rect_max_y))
                {
                    has_crossing = true;
                    break;
                }
            }

            if !has_crossing {
                let width = (rect_max_x - rect_min_x + 1) as i64;
                let height = (rect_max_y - rect_min_y + 1) as i64;
                let area = width * height;
                max_area = max(max_area, area);
            }
        }
    }

    max_area
}

fn is_inside_or_on_boundary(point: (i32, i32), polygon: &[(i32, i32)]) -> bool {
    // Check if on boundary first
    for i in 0..polygon.len() {
        let p1 = polygon[i];
        let p2 = polygon[(i + 1) % polygon.len()];

        if is_point_on_segment(point, p1, p2) {
            return true;
        }
    }

    // Use ray casting for interior check
    is_inside_polygon(point, polygon)
}

fn is_point_on_segment(point: (i32, i32), p1: (i32, i32), p2: (i32, i32)) -> bool {
    if p1.0 == p2.0 && p1.0 == point.0 {
        let min_y = min(p1.1, p2.1);
        let max_y = max(p1.1, p2.1);
        return point.1 >= min_y && point.1 <= max_y;
    }

    if p1.1 == p2.1 && p1.1 == point.1 {
        let min_x = min(p1.0, p2.0);
        let max_x = max(p1.0, p2.0);
        return point.0 >= min_x && point.0 <= max_x;
    }

    false
}

fn is_inside_polygon(point: (i32, i32), polygon: &[(i32, i32)]) -> bool {
    let mut intersections = 0;
    let n = polygon.len();

    for i in 0..n {
        let p1 = polygon[i];
        let p2 = polygon[(i + 1) % n];

        if (p1.1 > point.1) != (p2.1 > point.1) {
            let intersect_x = (p2.0 - p1.0) as f64 * (point.1 - p1.1) as f64 / (p2.1 - p1.1) as f64 + p1.0 as f64;
            if (point.0 as f64) < intersect_x {
                intersections += 1;
            }
        }
    }

    (intersections % 2) == 1
}

fn segments_properly_intersect(
    p1: (i32, i32),
    p2: (i32, i32),
    p3: (i32, i32),
    p4: (i32, i32),
) -> bool {
    let d1 = direction(p3, p4, p1);
    let d2 = direction(p3, p4, p2);
    let d3 = direction(p1, p2, p3);
    let d4 = direction(p1, p2, p4);

    ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))
}

fn direction(p1: (i32, i32), p2: (i32, i32), p3: (i32, i32)) -> i32 {
    let val = (p3.1 - p1.1) as i64 * (p2.0 - p1.0) as i64 - (p2.1 - p1.1) as i64 * (p3.0 - p1.0) as i64;
    if val == 0 {
        0
    } else if val > 0 {
        1
    } else {
        -1
    }
}

pub fn run() {
    crate::utils::run_solution("Part 1", part1, "../inputs/day09_test.txt", "../inputs/day09.txt", Some(50));
    crate::utils::run_solution("Part 2", part2, "../inputs/day09_test.txt", "../inputs/day09.txt", Some(24));
}
