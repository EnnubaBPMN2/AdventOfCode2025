use crate::utils;
use std::collections::HashMap;

pub fn run() {
    let test_input_path = "../inputs/day07_test.txt";
    let real_input_path = "../inputs/day07.txt";

    utils::run_solution("Part 1", part1, test_input_path, real_input_path, Some(21));
    utils::run_solution("Part 2", part2, test_input_path, real_input_path, Some(40));
}

pub fn part1(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let lines: Vec<&str> = input.lines().filter(|line| !line.is_empty()).collect();

    if lines.is_empty() {
        return 0;
    }

    let grid: Vec<Vec<char>> = lines.iter().map(|line| line.chars().collect()).collect();
    let height = grid.len();
    let width = grid[0].len();

    // Find starting position 'S'
    let mut start_row = 0;
    let mut start_col = 0;
    'outer: for row in 0..height {
        for col in 0..width {
            if grid[row][col] == 'S' {
                start_row = row;
                start_col = col;
                break 'outer;
            }
        }
    }

    // Simulate beams moving downward
    let mut current_beams = std::collections::HashSet::new();
    current_beams.insert(start_col);
    let mut split_count = 0;

    for row in start_row + 1..height {
        let mut next_beams = std::collections::HashSet::new();

        for &col in &current_beams {
            let cell = grid[row][col];

            if cell == '^' {
                // Splitter encountered
                split_count += 1;

                // Add beams to left and right
                if col > 0 {
                    next_beams.insert(col - 1);
                }
                if col + 1 < width {
                    next_beams.insert(col + 1);
                }
            } else {
                // Empty space - beam continues downward
                next_beams.insert(col);
            }
        }

        current_beams = next_beams;

        // If no beams left, we're done
        if current_beams.is_empty() {
            break;
        }
    }

    split_count
}

pub fn part2(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let lines: Vec<&str> = input.lines().filter(|line| !line.is_empty()).collect();

    if lines.is_empty() {
        return 0;
    }

    let grid: Vec<Vec<char>> = lines.iter().map(|line| line.chars().collect()).collect();
    let height = grid.len();
    let width = grid[0].len();

    // Find starting position 'S'
    let mut start_row = 0;
    let mut start_col = 0;
    'outer: for row in 0..height {
        for col in 0..width {
            if grid[row][col] == 'S' {
                start_row = row;
                start_col = col;
                break 'outer;
            }
        }
    }

    // For Part 2, track the number of distinct timelines/paths
    let mut current_paths = HashMap::new();
    current_paths.insert(start_col, 1i64);

    for row in start_row + 1..height {
        let mut next_paths = HashMap::new();

        for (&col, &path_count) in &current_paths {
            let cell = grid[row][col];

            if cell == '^' {
                // Splitter - particle takes both paths (quantum splitting)
                if col > 0 {
                    *next_paths.entry(col - 1).or_insert(0) += path_count;
                }
                if col + 1 < width {
                    *next_paths.entry(col + 1).or_insert(0) += path_count;
                }
            } else {
                // Empty space - particle continues downward
                *next_paths.entry(col).or_insert(0) += path_count;
            }
        }

        current_paths = next_paths;

        // If no paths left, we're done
        if current_paths.is_empty() {
            break;
        }
    }

    // Sum all timelines that reach the bottom
    current_paths.values().sum()
}
