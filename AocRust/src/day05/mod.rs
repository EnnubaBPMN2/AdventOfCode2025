use crate::utils;

pub fn run() {
    let test_input_path = "../inputs/day05_test.txt";
    let real_input_path = "../inputs/day05.txt";

    utils::run_solution("Part 1", part1, test_input_path, real_input_path, Some(3));
    utils::run_solution("Part 2", part2, test_input_path, real_input_path, Some(14));
}

pub fn part1(input: &str) -> i64 {
    let input = input.trim();
    // Handle both Unix and Windows line endings for section separator
    let sections: Vec<&str> = if input.contains("\r\n\r\n") {
        input.split("\r\n\r\n").collect()
    } else {
        input.split("\n\n").collect()
    };
    if sections.len() < 2 {
        return 0;
    }

    let mut ranges: Vec<(i64, i64)> = Vec::new();
    for line in sections[0].lines() {
        if let Some(dash_pos) = line.find('-') {
            if let (Ok(start), Ok(end)) = (
                line[..dash_pos].parse::<i64>(),
                line[dash_pos + 1..].parse::<i64>()
            ) {
                ranges.push((start, end));
            }
        }
    }

    let mut fresh_count = 0;
    for line in sections[1].lines() {
        if let Ok(id) = line.parse::<i64>() {
            for (start, end) in &ranges {
                if id >= *start && id <= *end {
                    fresh_count += 1;
                    break;
                }
            }
        }
    }

    fresh_count
}

pub fn part2(input: &str) -> i64 {
    let input = input.trim();
    // Handle both Unix and Windows line endings for section separator
    let sections: Vec<&str> = if input.contains("\r\n\r\n") {
        input.split("\r\n\r\n").collect()
    } else {
        input.split("\n\n").collect()
    };
    if sections.is_empty() {
        return 0;
    }

    let mut ranges: Vec<(i64, i64)> = Vec::new();
    for line in sections[0].lines() {
        if let Some(dash_pos) = line.find('-') {
            if let (Ok(start), Ok(end)) = (
                line[..dash_pos].parse::<i64>(),
                line[dash_pos + 1..].parse::<i64>()
            ) {
                ranges.push((start, end));
            }
        }
    }

    // Sort ranges by start
    ranges.sort_unstable_by_key(|r| r.0);

    let mut merged_ranges: Vec<(i64, i64)> = Vec::new();
    if !ranges.is_empty() {
        let mut current_range = ranges[0];
        for i in 1..ranges.len() {
            let next_range = ranges[i];
            // Check for overlap or adjacency
            if next_range.0 <= current_range.1 + 1 {
                current_range.1 = current_range.1.max(next_range.1);
            } else {
                merged_ranges.push(current_range);
                current_range = next_range;
            }
        }
        merged_ranges.push(current_range);
    }

    merged_ranges.iter().map(|(start, end)| end - start + 1).sum()
}
