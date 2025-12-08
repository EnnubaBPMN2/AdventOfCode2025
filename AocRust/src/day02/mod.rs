use crate::utils;

pub fn part1(input: &str) -> i64 {
    let input = input.trim();
    let mut total_invalid_sum = 0;

    for range in input.split(',') {
        let parts: Vec<&str> = range.split('-').collect();
        if parts.len() != 2 {
            continue;
        }

        if let (Ok(min), Ok(max)) = (parts[0].parse::<i64>(), parts[1].parse::<i64>()) {
            for i in min..=max {
                if is_invalid_id_part1(i) {
                    total_invalid_sum += i;
                }
            }
        }
    }

    total_invalid_sum
}

pub fn part2(input: &str) -> i64 {
    let input = input.trim();
    let mut total_invalid_sum = 0;

    for range in input.split(',') {
        let parts: Vec<&str> = range.split('-').collect();
        if parts.len() != 2 {
            continue;
        }

        if let (Ok(min), Ok(max)) = (parts[0].parse::<i64>(), parts[1].parse::<i64>()) {
            for i in min..=max {
                if is_invalid_id_part2(i) {
                    total_invalid_sum += i;
                }
            }
        }
    }

    total_invalid_sum
}

fn is_invalid_id_part1(n: i64) -> bool {
    let s = n.to_string();
    if s.len() % 2 != 0 {
        return false;
    }

    let half = s.len() / 2;
    let first_half = &s[0..half];
    let second_half = &s[half..];

    first_half == second_half
}

fn is_invalid_id_part2(n: i64) -> bool {
    let s = n.to_string();
    let len = s.len();

    // Try all possible pattern lengths L
    // The pattern must repeat at least twice, so L can go up to len / 2
    for l in 1..=(len / 2) {
        if len % l == 0 {
            let k = len / l; // Number of repetitions
            // k is guaranteed to be >= 2 because l <= len / 2

            let pattern = &s[0..l];
            
            // Check if s is composed of k repetitions of pattern
            // We can construct the expected string and compare
            let repeated = pattern.repeat(k);
            if repeated == s {
                return true;
            }
        }
    }

    false
}

pub fn run() {
    utils::run_solution("Part 1", part1, "../inputs/day02_test.txt", "../inputs/day02.txt", Some(1227775554));
    utils::run_solution("Part 2", part2, "../inputs/day02_test.txt", "../inputs/day02.txt", Some(4174379265));
}
