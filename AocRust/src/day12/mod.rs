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

    // Precompute all shape orientations once
    let all_orientations: Vec<Vec<Shape>> = shapes
        .iter()
        .map(|s| get_all_orientations(s))
        .collect();

    let mut count = 0;
    for region in &regions {
        if can_fit_all_presents(region, &all_orientations) {
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

#[derive(Debug, Clone)]
struct Shape {
    rows: Vec<usize>,
    cols: Vec<usize>,
    width: usize,
    height: usize,
    area: usize,
}

impl Shape {
    fn from_strings(lines: &[String]) -> Self {
        let mut rows = Vec::new();
        let mut cols = Vec::new();

        for (r, line) in lines.iter().enumerate() {
            for (c, ch) in line.chars().enumerate() {
                if ch == '#' {
                    rows.push(r);
                    cols.push(c);
                }
            }
        }

        let height = lines.len();
        let width = lines.iter().map(|l| l.len()).max().unwrap_or(0);
        let area = rows.len();

        Shape {
            rows,
            cols,
            width,
            height,
            area,
        }
    }
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

fn can_fit_all_presents(region: &Region, all_orientations: &[Vec<Shape>]) -> bool {
    // Quick area check
    let total_area = region.width * region.height;
    let mut required_area = 0;

    for (i, &count) in region.counts.iter().enumerate() {
        if count > 0 {
            let shape_area = all_orientations[i][0].area;
            required_area += shape_area * count;
        }
    }

    if required_area > total_area {
        return false;
    }

    // Use flat 1D array for better cache performance
    let mut grid = vec![false; region.width * region.height];
    let mut counts = region.counts.clone();

    try_place_presents(&mut grid, region.width, region.height, &mut counts, all_orientations, 0)
}

fn try_place_presents(
    grid: &mut [bool],
    width: usize,
    height: usize,
    counts: &mut [usize],
    all_orientations: &[Vec<Shape>],
    call_count: i32,
) -> bool {
    if call_count > 2_000_000 {
        return false;
    }

    // Check if all presents are placed
    if counts.iter().all(|&count| count == 0) {
        return true;
    }

    // Find first empty cell
    let start_idx = match grid.iter().position(|&cell| !cell) {
        Some(idx) => idx,
        None => return false, // No empty cell but presents remain - impossible
    };

    let start_row = start_idx / width;
    let start_col = start_idx % width;

    // Try each shape type
    for shape_idx in 0..counts.len() {
        if counts[shape_idx] == 0 {
            continue;
        }

        let orientations = &all_orientations[shape_idx];

        // Try each orientation
        for shape in orientations {
            // Can we place this shape at the first empty position?
            if can_place_shape(grid, width, height, shape, start_row, start_col) {
                place_shape(grid, width, shape, start_row, start_col);
                counts[shape_idx] -= 1;

                if try_place_presents(grid, width, height, counts, all_orientations, call_count + 1) {
                    return true;
                }

                remove_shape(grid, width, shape, start_row, start_col);
                counts[shape_idx] += 1;
            }
        }
    }

    false
}

fn can_place_shape(
    grid: &[bool],
    width: usize,
    height: usize,
    shape: &Shape,
    start_row: usize,
    start_col: usize,
) -> bool {
    if start_row + shape.height > height {
        return false;
    }
    if start_col + shape.width > width {
        return false;
    }

    for i in 0..shape.rows.len() {
        let r = shape.rows[i];
        let c = shape.cols[i];
        let grid_idx = (start_row + r) * width + (start_col + c);

        if grid[grid_idx] {
            return false;
        }
    }

    true
}

fn place_shape(grid: &mut [bool], width: usize, shape: &Shape, start_row: usize, start_col: usize) {
    for i in 0..shape.rows.len() {
        let r = shape.rows[i];
        let c = shape.cols[i];
        let grid_idx = (start_row + r) * width + (start_col + c);
        grid[grid_idx] = true;
    }
}

fn remove_shape(grid: &mut [bool], width: usize, shape: &Shape, start_row: usize, start_col: usize) {
    for i in 0..shape.rows.len() {
        let r = shape.rows[i];
        let c = shape.cols[i];
        let grid_idx = (start_row + r) * width + (start_col + c);
        grid[grid_idx] = false;
    }
}

fn get_all_orientations(shape_template: &[String]) -> Vec<Shape> {
    let mut orientations = HashSet::new();
    let mut current = shape_template.to_vec();

    for _ in 0..4 {
        orientations.insert(current.join("|"));

        // Also add flipped version
        let flipped = flip(&current);
        orientations.insert(flipped.join("|"));

        current = rotate(&current);
    }

    orientations
        .into_iter()
        .map(|s| {
            let lines: Vec<String> = s.split('|').map(|part| part.to_string()).collect();
            Shape::from_strings(&lines)
        })
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
