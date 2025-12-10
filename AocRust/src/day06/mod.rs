use crate::utils;

pub fn run() {
    let test_input_path = "../inputs/day06_test.txt";
    let real_input_path = "../inputs/day06.txt";

    utils::run_solution("Part 1", part1, test_input_path, real_input_path, Some(4277556));
    utils::run_solution("Part 2", part2, test_input_path, real_input_path, Some(3263827));
}

pub fn part1(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let lines: Vec<&str> = input.lines().filter(|line| !line.is_empty()).collect();

    if lines.is_empty() {
        return 0;
    }

    let height = lines.len();
    let width = lines.iter().map(|line| line.len()).max().unwrap_or(0);

    // OPTIMIZATION: Convert to Vec<Vec<u8>> for O(1) character access
    // This fixes the O(n) chars().nth() bottleneck
    let grid: Vec<Vec<u8>> = lines
        .iter()
        .map(|line| {
            let mut bytes = line.as_bytes().to_vec();
            bytes.resize(width, b' ');
            bytes
        })
        .collect();

    let mut problems: Vec<(Vec<i64>, char)> = Vec::new();
    let mut start_col: Option<usize> = None;

    for col in 0..width {
        let mut is_empty_col = true;
        for row in 0..height {
            // O(1) access instead of O(n) chars().nth()
            if grid[row][col] != b' ' {
                is_empty_col = false;
                break;
            }
        }

        if !is_empty_col {
            if start_col.is_none() {
                start_col = Some(col);
            }
        } else {
            if let Some(start) = start_col {
                // End of a block
                problems.push(parse_problem(&grid, start, col - 1));
                start_col = None;
            }
        }
    }

    // Handle last block if it extends to the edge
    if let Some(start) = start_col {
        problems.push(parse_problem(&grid, start, width - 1));
    }

    let mut total = 0;
    for (numbers, op) in problems {
        let mut result = numbers[0];
        for i in 1..numbers.len() {
            if op == '+' {
                result += numbers[i];
            } else if op == '*' {
                result *= numbers[i];
            }
        }
        total += result;
    }

    total
}

fn parse_problem(grid: &[Vec<u8>], start_col: usize, end_col: usize) -> (Vec<i64>, char) {
    let mut numbers: Vec<i64> = Vec::new();
    let mut op = ' ';

    let height = grid.len();

    // Numbers are in all rows except the last
    for row in 0..height - 1 {
        let substring = String::from_utf8_lossy(&grid[row][start_col..=end_col]).trim().to_string();
        if !substring.is_empty() {
            if let Ok(num) = substring.parse::<i64>() {
                numbers.push(num);
            }
        }
    }

    // Operator is in the last row
    let op_string = String::from_utf8_lossy(&grid[height - 1][start_col..=end_col]).trim().to_string();
    if !op_string.is_empty() {
        op = op_string.chars().next().unwrap();
    }

    (numbers, op)
}

pub fn part2(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let lines: Vec<&str> = input.lines().filter(|line| !line.is_empty()).collect();

    if lines.is_empty() {
        return 0;
    }

    let height = lines.len();
    let width = lines.iter().map(|line| line.len()).max().unwrap_or(0);

    // OPTIMIZATION: Convert to Vec<Vec<u8>> for O(1) character access
    let grid: Vec<Vec<u8>> = lines
        .iter()
        .map(|line| {
            let mut bytes = line.as_bytes().to_vec();
            bytes.resize(width, b' ');
            bytes
        })
        .collect();

    let mut problems: Vec<(Vec<i64>, char)> = Vec::new();
    let mut start_col: Option<usize> = None;

    for col in 0..width {
        let mut is_empty_col = true;
        for row in 0..height {
            // O(1) access instead of O(n) chars().nth()
            if grid[row][col] != b' ' {
                is_empty_col = false;
                break;
            }
        }

        if !is_empty_col {
            if start_col.is_none() {
                start_col = Some(col);
            }
        } else {
            if let Some(start) = start_col {
                // End of a block - parse reading right-to-left
                problems.push(parse_problem_right_to_left(&grid, start, col - 1));
                start_col = None;
            }
        }
    }

    // Handle last block if it extends to the edge
    if let Some(start) = start_col {
        problems.push(parse_problem_right_to_left(&grid, start, width - 1));
    }

    let mut total = 0;
    for (numbers, op) in problems {
        let mut result = numbers[0];
        for i in 1..numbers.len() {
            if op == '+' {
                result += numbers[i];
            } else if op == '*' {
                result *= numbers[i];
            }
        }
        total += result;
    }

    total
}

fn parse_problem_right_to_left(grid: &[Vec<u8>], start_col: usize, end_col: usize) -> (Vec<i64>, char) {
    let mut numbers: Vec<i64> = Vec::new();
    let mut op = ' ';

    let height = grid.len();

    // Read each column from right to left
    for col in (start_col..=end_col).rev() {
        let mut digit_chars: Vec<u8> = Vec::new();

        // Read digits from top to bottom in this column (rows 0 to height-2, excluding operator row)
        for row in 0..height - 1 {
            // O(1) access instead of O(n) chars().nth()
            let c = grid[row][col];
            if c != b' ' {
                digit_chars.push(c);
            }
        }

        // Build number from these digits
        if !digit_chars.is_empty() {
            let num_str = String::from_utf8_lossy(&digit_chars).to_string();
            if let Ok(num) = num_str.parse::<i64>() {
                numbers.push(num);
            }
        }
    }

    // Operator is in the last row - find it anywhere in this block
    for col in start_col..=end_col {
        // O(1) access instead of O(n) chars().nth()
        let c = grid[height - 1][col] as char;
        if c == '+' || c == '*' {
            op = c;
            break;
        }
    }

    (numbers, op)
}
