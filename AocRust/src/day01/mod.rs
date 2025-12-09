/// Advent of Code 2025 - Day 01: Secret Entrance

use crate::utils;

/// Count how many times the dial points at 0 after rotations
pub fn part1(input: &str) -> i32 {
    let rotations = input.split_whitespace();
    
    let mut position: i32 = 50; // Starting position
    let mut zero_count = 0;
    
    for rotation in rotations {
        if rotation.is_empty() { continue; }
        if rotation.len() < 2 { continue; }
        // println!("DEBUG: '{}'", rotation);
        let direction = rotation.chars().next().unwrap();
        let distance_str = rotation[1..].trim();
        let distance: i32 = distance_str.parse().expect(&format!("Failed to parse distance from '{}'", rotation));
        
        match direction {
            'L' => {
                position = (position - distance).rem_euclid(100);
            }
            'R' => {
                position = (position + distance).rem_euclid(100);
            }
            _ => {}
        }
        
        if position == 0 {
            zero_count += 1;
        }
    }
    
    zero_count
}

/// Part 2: Count number of times dial points at 0 during rotations
pub fn part2(input: &str) -> i32 {
    let rotations = input.split_whitespace();
    
    let mut position: i32 = 50; // Starting position
    let mut zero_count = 0;
    
    for rotation in rotations {
        if rotation.is_empty() { continue; }
        if rotation.len() < 2 { continue; }
        // println!("DEBUG: '{}'", rotation);
        let direction = rotation.chars().next().unwrap();
        let distance_str = rotation[1..].trim();
        let distance: i32 = distance_str.parse().expect(&format!("Failed to parse distance from '{}'", rotation));
        
        match direction {
            'R' => {
                // Moving right: count multiples of 100 in range (position, position + distance]
                zero_count += (position + distance) / 100;
                position = (position + distance).rem_euclid(100);
            }
            'L' => {
                // Moving left: count multiples of 100 in range [position - distance, position)
                // Count = floor((pos - 1) / 100) - floor((pos - dist - 1) / 100)
                
                let start_floor = if (position - 1) < 0 { -1 } else { 0 };
                let end_floor = (position - distance - 1).div_euclid(100);
                
                zero_count += start_floor - end_floor;
                position = (position - distance).rem_euclid(100);
            }
            _ => {}
        }
    }
    
    zero_count
}

/// Run Day 01 solutions
pub fn run() {
    let test_input_path = "../inputs/day01_test.txt";
    let input_path = "../inputs/day01.txt";
    
    // Part 1
    utils::run_solution(
        "Part 1",
        part1,
        test_input_path,
        input_path,
        Some(3),
    );
    
    // Part 2
    utils::run_solution(
        "Part 2",
        part2,
        test_input_path,
        input_path,
        Some(6),
    );
}
