use crate::utils;
use std::collections::HashSet;

pub fn run() {
    let test_input_path = "../inputs/day12_test.txt";
    let real_input_path = "../inputs/day12.txt";

    utils::run_solution("Part 1", part1, test_input_path, real_input_path, Some(2));
    println!("\n🎄 Part 2 automatically completed! Both stars earned! 🎄\n");
}

pub fn part1(input: &str) -> i64 {
    let (shapes, regions) = parse_input(input);

    let mut count = 0;
    for region in &regions {
        if can_fit_all_presents(region, &shapes) {
            count += 1;
        }
    }

    count
}

#[derive(Debug, Clone)]
struct Region {
    width: usize,
    height: usize,
    counts: Vec<usize>,
}

fn parse_input(input: &str) -> (Vec<Vec<String>>, Vec<Region>) {
    let input = input.replace("\r", "");
    let lines: Vec<&str> = input.split('\n').collect();
    let mut shapes = Vec::new();
    let mut regions = Vec::new();

    let mut i = 0;
    while i < lines.len() {
        let line = lines[i];

        // Parse region (check this first since it also contains ':')
        if line.contains('x') && line.contains(':') {
            let parts: Vec<&str> = line.split(':').collect();
            let dimensions: Vec<&str> = parts[0].trim().split('x').collect();
            let width = dimensions[0].parse::<usize>().unwrap();
            let height = dimensions[1].parse::<usize>().unwrap();

            let counts: Vec<usize> = parts[1]
                .trim()
                .split_whitespace()
                .map(|s| s.parse().unwrap())
                .collect();

            regions.push(Region { width, height, counts });
            i += 1;
        }
        // Parse shape
        else if line.contains(':') {
            let mut shape_lines = Vec::new();
            i += 1; // Skip the label line

            while i < lines.len() && !lines[i].trim().is_empty() && !lines[i].contains(':') {
                shape_lines.push(lines[i].to_string());
                i += 1;
            }

            if !shape_lines.is_empty() {
                shapes.push(shape_lines);
            }
        } else {
            i += 1;
        }
    }

    (shapes, regions)
}

fn can_fit_all_presents(region: &Region, shape_templates: &[Vec<String>]) -> bool {
    // Quick area check - if total shape area exceeds grid area, impossible
    let total_area = region.width * region.height;
    let mut required_area = 0;

    for (i, &count) in region.counts.iter().enumerate() {
        if count > 0 {
            let shape_area = get_shape_area(&shape_templates[i]);
            required_area += shape_area * count;
        }
    }

    if required_area > total_area {
        return false;
    }

    // Initialize grid
    let mut grid = vec![vec!['.'; region.width]; region.height];

    // Build list of presents to place
    let mut presents = Vec::new();
    for (i, &count) in region.counts.iter().enumerate() {
        if count > 0 {
            presents.push((i, count));
        }
    }

    // Try to place all presents
    let mut call_count = 0;
    try_place_presents(&mut grid, &presents, shape_templates, b'A', &mut call_count)
}

fn get_shape_area(shape: &[String]) -> usize {
    let mut area = 0;
    for row in shape {
        area += row.chars().filter(|&c| c == '#').count();
    }
    area
}

fn try_place_presents(
    grid: &mut Vec<Vec<char>>,
    presents: &[(usize, usize)],
    shape_templates: &[Vec<String>],
    label: u8,
    call_count: &mut i32,
) -> bool {
    *call_count += 1;
    if *call_count > 2_000_000 {
        return false; // Fail faster on impossible regions
    }

    // Check if all presents are placed
    if presents.iter().all(|(_, count)| *count == 0) {
        return true;
    }

    // Try placing first available present type
    for i in 0..presents.len() {
        let (shape_index, count) = presents[i];
        if count == 0 {
            continue;
        }

        let shapes = get_all_orientations(&shape_templates[shape_index]);

        for shape in &shapes {
            // Try placing at every position
            for row in 0..grid.len() {
                for col in 0..grid[0].len() {
                    if can_place_shape(grid, shape, row, col) {
                        place_shape(grid, shape, row, col, label as char);

                        // Create new presents list with one less of this shape
                        let mut new_presents = presents.to_vec();
                        new_presents[i] = (shape_index, count - 1);

                        if try_place_presents(grid, &new_presents, shape_templates, label.wrapping_add(1), call_count) {
                            return true;
                        }

                        remove_shape(grid, shape, row, col);
                    }
                }
            }
        }

        // If we couldn't place this present type anywhere, fail
        return false;
    }

    true // All presents placed
}

fn get_all_orientations(shape: &[String]) -> Vec<Vec<String>> {
    let mut orientations = HashSet::new();
    let mut current = shape.to_vec();

    for _ in 0..4 {
        orientations.insert(current.join("|"));

        // Also add flipped version
        let flipped = flip(&current);
        orientations.insert(flipped.join("|"));

        current = rotate(&current);
    }

    orientations
        .into_iter()
        .map(|s| s.split('|').map(|part| part.to_string()).collect())
        .collect()
}

fn rotate(shape: &[String]) -> Vec<String> {
    let rows = shape.len();
    let cols = shape[0].len();
    let mut rotated = Vec::new();

    for c in 0..cols {
        let mut new_row = String::new();
        for r in 0..rows {
            new_row.push(shape[rows - 1 - r].chars().nth(c).unwrap());
        }
        rotated.push(new_row);
    }

    rotated
}

fn flip(shape: &[String]) -> Vec<String> {
    shape.iter().map(|row| row.chars().rev().collect()).collect()
}

fn can_place_shape(grid: &[Vec<char>], shape: &[String], start_row: usize, start_col: usize) -> bool {
    let grid_rows = grid.len();
    let grid_cols = grid[0].len();

    // Check if the shape fits within grid bounds
    if start_row + shape.len() > grid_rows {
        return false;
    }

    let max_shape_width = shape.iter().map(|row| row.len()).max().unwrap_or(0);
    if start_col + max_shape_width > grid_cols {
        return false;
    }

    for (r, row) in shape.iter().enumerate() {
        for (c, cell) in row.chars().enumerate() {
            if cell == '#' {
                let grid_row = start_row + r;
                let grid_col = start_col + c;

                // Only check '#' cells - '.' cells in the shape can overlap anything
                if grid[grid_row][grid_col] != '.' {
                    return false;
                }
            }
        }
    }

    true
}

fn place_shape(grid: &mut Vec<Vec<char>>, shape: &[String], start_row: usize, start_col: usize, label: char) {
    for (r, row) in shape.iter().enumerate() {
        for (c, cell) in row.chars().enumerate() {
            if cell == '#' {
                grid[start_row + r][start_col + c] = label;
            }
        }
    }
}

fn remove_shape(grid: &mut Vec<Vec<char>>, shape: &[String], start_row: usize, start_col: usize) {
    for (r, row) in shape.iter().enumerate() {
        for (c, cell) in row.chars().enumerate() {
            if cell == '#' {
                grid[start_row + r][start_col + c] = '.';
            }
        }
    }
}
