use crate::utils;

pub fn part1(input: &str) -> i64 {
    let input = input.trim();
    let mut total_output_joltage = 0;

    for line in input.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let bytes = line.as_bytes();
        let mut max_joltage = -1;

        for i in 0..bytes.len() {
            let digit_i = (bytes[i] - b'0') as i64;
            for j in (i + 1)..bytes.len() {
                let digit_j = (bytes[j] - b'0') as i64;
                let joltage = digit_i * 10 + digit_j;
                if joltage > max_joltage {
                    max_joltage = joltage;
                }
            }
        }

        if max_joltage != -1 {
            total_output_joltage += max_joltage;
        }
    }

    total_output_joltage
}

pub fn part2(input: &str) -> i64 {
    let input = input.trim();
    let mut total_output_joltage = 0;
    let k = 12;

    for line in input.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let bytes = line.as_bytes();
        let mut stack: Vec<u8> = Vec::with_capacity(k);
        let n = bytes.len();

        for i in 0..n {
            let digit = bytes[i] - b'0';
            let remaining = n - 1 - i;

            while !stack.is_empty() && digit > *stack.last().unwrap() && stack.len() + remaining >= k {
                stack.pop();
            }

            if stack.len() < k {
                stack.push(digit);
            }
        }

        // Construct the number directly from digits
        let mut max_joltage: i64 = 0;
        for &digit in &stack {
            max_joltage = max_joltage * 10 + digit as i64;
        }

        total_output_joltage += max_joltage;
    }

    total_output_joltage
}

pub fn run() {
    utils::run_solution("Part 1", part1, "../inputs/day03_test.txt", "../inputs/day03.txt", Some(357));
    utils::run_solution("Part 2", part2, "../inputs/day03_test.txt", "../inputs/day03.txt", Some(3121910778619));
}
