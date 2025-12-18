use crate::utils;
use regex::Regex;

pub fn run() {
    let test_input_path = "../inputs/day10_test.txt";
    let real_input_path = "../inputs/day10.txt";

    utils::run_solution("Part 1", part1, test_input_path, real_input_path, Some(7));
    utils::run_solution("Part 2", part2, test_input_path, real_input_path, Some(33));
}

pub fn part1(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let lines: Vec<&str> = input.lines().filter(|line| !line.is_empty()).collect();

    let mut total_presses = 0;

    for line in lines {
        let (target, buttons) = parse_machine(line);
        let min_presses = solve_gaussian_elimination(&target, &buttons);
        total_presses += min_presses;
    }

    total_presses
}

pub fn part2(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let lines: Vec<&str> = input.lines().filter(|line| !line.is_empty()).collect();

    let mut total_presses = 0;

    for line in lines {
        let (targets, buttons) = parse_machine_part2(line);
        let min_presses = solve_integer_linear_programming(&targets, &buttons);
        total_presses += min_presses;
    }

    total_presses
}

fn parse_machine(line: &str) -> (Vec<bool>, Vec<Vec<bool>>) {
    let indicator_re = Regex::new(r"\[(\.|\#)+\]").unwrap();
    let button_re = Regex::new(r"\([\d,]+\)").unwrap();

    // Extract indicator pattern
    let indicator_match = indicator_re.find(line).unwrap();
    let indicator = indicator_match.as_str().trim_matches(|c| c == '[' || c == ']');
    let target: Vec<bool> = indicator.chars().map(|c| c == '#').collect();

    // Extract button patterns
    let mut buttons = Vec::new();
    for cap in button_re.find_iter(line) {
        let button_str = cap.as_str().trim_matches(|c| c == '(' || c == ')');
        let indices: Vec<usize> = button_str.split(',').map(|s| s.parse().unwrap()).collect();

        let mut button = vec![false; target.len()];
        for &idx in &indices {
            button[idx] = true;
        }
        buttons.push(button);
    }

    (target, buttons)
}

fn solve_gaussian_elimination(target: &[bool], buttons: &[Vec<bool>]) -> i64 {
    let num_lights = target.len();
    let num_buttons = buttons.len();

    // Build augmented matrix [A | b] for GF(2)
    let mut matrix = vec![vec![false; num_buttons + 1]; num_lights];

    for light in 0..num_lights {
        for button in 0..num_buttons {
            matrix[light][button] = buttons[button][light];
        }
        matrix[light][num_buttons] = target[light];
    }

    // Perform Gaussian elimination in GF(2)
    let mut pivot = vec![-1i32; num_lights];

    let mut col = 0;
    let mut row = 0;
    while row < num_lights && col < num_buttons {
        // Find pivot
        let mut pivot_row = None;
        for r in row..num_lights {
            if matrix[r][col] {
                pivot_row = Some(r);
                break;
            }
        }

        if pivot_row.is_none() {
            col += 1;
            continue;
        }

        let pivot_row = pivot_row.unwrap();

        // Swap rows
        if pivot_row != row {
            matrix.swap(row, pivot_row);
        }

        pivot[row] = col as i32;

        // Eliminate column
        for r in 0..num_lights {
            if r != row && matrix[r][col] {
                for c in 0..=num_buttons {
                    matrix[r][c] ^= matrix[row][c];
                }
            }
        }

        row += 1;
        col += 1;
    }

    // Check for inconsistency
    for r in 0..num_lights {
        let all_zero = (0..num_buttons).all(|c| !matrix[r][c]);
        if all_zero && matrix[r][num_buttons] {
            return i64::MAX;
        }
    }

    // Find free variables
    let mut free_vars = Vec::new();
    for c in 0..num_buttons {
        let is_pivot = pivot.iter().any(|&p| p == c as i32);
        if !is_pivot {
            free_vars.push(c);
        }
    }

    let mut min_presses = i64::MAX;
    let max_combinations = std::cmp::min(1 << free_vars.len(), 1 << 15);

    for mask in 0..max_combinations {
        let mut solution = vec![false; num_buttons];

        // Set free variables based on mask
        for (i, &var) in free_vars.iter().enumerate().take(15) {
            solution[var] = ((mask >> i) & 1) == 1;
        }

        // Back-substitute for pivot variables
        for r in (0..num_lights).rev() {
            if pivot[r] == -1 {
                continue;
            }

            let pivot_col = pivot[r] as usize;
            let mut val = matrix[r][num_buttons];
            for c in (pivot_col + 1)..num_buttons {
                if matrix[r][c] && solution[c] {
                    val ^= true;
                }
            }
            solution[pivot_col] = val;
        }

        // Count presses
        let presses = solution.iter().filter(|&&x| x).count() as i64;
        min_presses = std::cmp::min(min_presses, presses);
    }

    min_presses
}

fn parse_machine_part2(line: &str) -> (Vec<i64>, Vec<Vec<i64>>) {
    let jolts_re = Regex::new(r"\{[\d,]+\}").unwrap();
    let button_re = Regex::new(r"\([\d,]+\)").unwrap();

    // Extract joltage requirements
    let jolts_match = jolts_re.find(line).unwrap();
    let jolts_str = jolts_match.as_str().trim_matches(|c| c == '{' || c == '}');
    let targets: Vec<i64> = jolts_str.split(',').map(|s| s.parse().unwrap()).collect();

    // Extract button patterns
    let mut buttons = Vec::new();
    for cap in button_re.find_iter(line) {
        let button_str = cap.as_str().trim_matches(|c| c == '(' || c == ')');
        let indices: Vec<usize> = button_str.split(',').map(|s| s.parse().unwrap()).collect();

        let mut button = vec![0i64; targets.len()];
        for &idx in &indices {
            button[idx] = 1;
        }
        buttons.push(button);
    }

    (targets, buttons)
}

fn solve_integer_linear_programming(targets: &[i64], buttons: &[Vec<i64>]) -> i64 {
    let num_counters = targets.len();
    let num_buttons = buttons.len();

    // Build matrix [A | b]
    let mut matrix = vec![vec![0.0; num_buttons + 1]; num_counters];

    for counter in 0..num_counters {
        for button in 0..num_buttons {
            matrix[counter][button] = buttons[button][counter] as f64;
        }
        matrix[counter][num_buttons] = targets[counter] as f64;
    }

    // Perform Gaussian elimination to get RREF
    let mut pivot = vec![-1i32; num_counters];

    let mut col = 0;
    let mut row = 0;
    while row < num_counters && col < num_buttons {
        // Find pivot
        let mut pivot_row = None;
        for r in row..num_counters {
            if matrix[r][col].abs() > 1e-9 {
                pivot_row = Some(r);
                break;
            }
        }

        if pivot_row.is_none() {
            col += 1;
            continue;
        }

        let pivot_row = pivot_row.unwrap();

        // Swap rows
        if pivot_row != row {
            matrix.swap(row, pivot_row);
        }

        pivot[row] = col as i32;

        // Scale pivot row
        let pivot_val = matrix[row][col];
        for c in 0..=num_buttons {
            matrix[row][c] /= pivot_val;
        }

        // Eliminate column
        for r in 0..num_counters {
            if r != row && matrix[r][col].abs() > 1e-9 {
                let factor = matrix[r][col];
                for c in 0..=num_buttons {
                    matrix[r][c] -= factor * matrix[row][c];
                }
            }
        }

        row += 1;
        col += 1;
    }

    // Find free variables
    let mut free_vars = Vec::new();
    for c in 0..num_buttons {
        let is_pivot = pivot.iter().any(|&p| p == c as i32);
        if !is_pivot {
            free_vars.push(c);
        }
    }

    let mut min_presses = i64::MAX;

    // For systems with no free variables, there's a unique solution
    if free_vars.is_empty() {
        let mut solution = vec![0i64; num_buttons];

        for r in 0..num_counters {
            if pivot[r] == -1 {
                continue;
            }

            let val = matrix[r][num_buttons];
            if val < -1e-9 || (val - val.round()).abs() > 1e-9 {
                return 0;
            }

            let rounded_val = val.round() as i64;
            if rounded_val < 0 {
                return 0;
            }

            solution[pivot[r] as usize] = rounded_val;
        }

        return solution.iter().sum();
    }

    // Use recursive search with pruning for free variables
    let mut current_solution = vec![0i64; num_buttons];
    let max_free_value = *targets.iter().max().unwrap();

    fn search_solutions(
        free_var_idx: usize,
        free_vars: &[usize],
        current_solution: &mut Vec<i64>,
        matrix: &[Vec<f64>],
        pivot: &[i32],
        num_counters: usize,
        num_buttons: usize,
        min_presses: &mut i64,
        max_free_value: i64,
    ) {
        if free_var_idx == free_vars.len() {
            // Back-substitute for pivot variables
            let mut test_solution = current_solution.clone();
            let mut valid = true;

            for r in (0..num_counters).rev() {
                if pivot[r] == -1 {
                    continue;
                }

                let pivot_col = pivot[r] as usize;
                let mut val = matrix[r][num_buttons];
                for c in (pivot_col + 1)..num_buttons {
                    if matrix[r][c].abs() > 1e-9 {
                        val -= matrix[r][c] * test_solution[c] as f64;
                    }
                }

                if val < -1e-9 || (val - val.round()).abs() > 1e-9 {
                    valid = false;
                    break;
                }

                let rounded_val = val.round() as i64;
                if rounded_val < 0 {
                    valid = false;
                    break;
                }

                test_solution[pivot_col] = rounded_val;
            }

            if valid {
                let presses: i64 = test_solution.iter().sum();
                *min_presses = std::cmp::min(*min_presses, presses);
            }
            return;
        }

        // Try values for this free variable
        let var_idx = free_vars[free_var_idx];
        let current_sum: i64 = current_solution.iter().sum();
        let upper_bound = std::cmp::min(max_free_value, *min_presses - current_sum);

        for value in 0..=upper_bound {
            current_solution[var_idx] = value;
            search_solutions(
                free_var_idx + 1,
                free_vars,
                current_solution,
                matrix,
                pivot,
                num_counters,
                num_buttons,
                min_presses,
                max_free_value,
            );

            // Early exit if found perfect solution
            if *min_presses == 0 {
                return;
            }
        }
        current_solution[var_idx] = 0;
    }

    search_solutions(
        0,
        &free_vars,
        &mut current_solution,
        &matrix,
        &pivot,
        num_counters,
        num_buttons,
        &mut min_presses,
        max_free_value,
    );

    if min_presses == i64::MAX {
        0
    } else {
        min_presses
    }
}
