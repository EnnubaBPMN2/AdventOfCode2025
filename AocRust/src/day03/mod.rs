use crate::utils;

pub fn part1(input: &str) -> i64 {
    let input = input.trim();
    let mut total_output_joltage = 0;

    for line in input.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let digits: Vec<i64> = line.chars()
            .filter_map(|c| c.to_digit(10))
            .map(|d| d as i64)
            .collect();
        
        let mut max_joltage = -1;

        for i in 0..digits.len() {
            for j in (i + 1)..digits.len() {
                let joltage = digits[i] * 10 + digits[j];
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

        let digits: Vec<u32> = line.chars()
            .filter_map(|c| c.to_digit(10))
            .collect();
        
        let mut stack: Vec<u32> = Vec::new();
        let n = digits.len();

        for (i, &digit) in digits.iter().enumerate() {
            let remaining = n - 1 - i;

            while !stack.is_empty() && digit > *stack.last().unwrap() && stack.len() + remaining >= k {
                stack.pop();
            }

            if stack.len() < k {
                stack.push(digit);
            }
        }

        if stack.len() == k {
            let number_str: String = stack.iter().map(|d| d.to_string()).collect();
            if let Ok(val) = number_str.parse::<i64>() {
                total_output_joltage += val;
            }
        }
    }

    total_output_joltage
}

pub fn run() {
    utils::run_solution("Part 1", part1, "../inputs/day03_test.txt", "../inputs/day03.txt", Some(357));
    utils::run_solution("Part 2", part2, "../inputs/day03_test.txt", "../inputs/day03.txt", Some(3121910778619));
}
