use crate::utils;

pub fn run() {
    let test_input_path = "../inputs/day05_test.txt";
    let real_input_path = "../inputs/day05.txt";

    utils::run_solution("Part 1", part1, test_input_path, real_input_path, Some(3));
    utils::run_solution("Part 2", part2, test_input_path, real_input_path, Some(14));
}

pub fn part1(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let sections: Vec<&str> = input.trim().split("\n\n").collect();
    if sections.len() < 2 {
        return 0;
    }

    let range_lines: Vec<&str> = sections[0].lines().collect();
    let id_lines: Vec<&str> = sections[1].lines().collect();

    let mut ranges: Vec<(i64, i64)> = Vec::new();
    for line in range_lines {
        let parts: Vec<&str> = line.split('-').collect();
        if parts.len() == 2 {
            if let (Ok(start), Ok(end)) = (parts[0].parse::<i64>(), parts[1].parse::<i64>()) {
                ranges.push((start, end));
            }
        }
    }

    let mut ids: Vec<i64> = Vec::new();
    for line in id_lines {
        if let Ok(id) = line.parse::<i64>() {
            ids.push(id);
        }
    }

    let mut fresh_count = 0;
    for id in ids {
        let mut is_fresh = false;
        for (start, end) in &ranges {
            if id >= *start && id <= *end {
                is_fresh = true;
                break;
            }
        }

        if is_fresh {
            fresh_count += 1;
        }
    }

    fresh_count
}

pub fn part2(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let sections: Vec<&str> = input.trim().split("\n\n").collect();
    if sections.is_empty() {
        return 0;
    }

    let range_lines: Vec<&str> = sections[0].lines().collect();
    let mut ranges: Vec<(i64, i64)> = Vec::new();
    for line in range_lines {
        let parts: Vec<&str> = line.split('-').collect();
        if parts.len() == 2 {
            if let (Ok(start), Ok(end)) = (parts[0].parse::<i64>(), parts[1].parse::<i64>()) {
                ranges.push((start, end));
            }
        }
    }

    // Sort ranges by start
    ranges.sort_by(|a, b| a.0.cmp(&b.0));

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

    let mut total_fresh = 0;
    for (start, end) in merged_ranges {
        total_fresh += end - start + 1;
    }

    total_fresh
}
