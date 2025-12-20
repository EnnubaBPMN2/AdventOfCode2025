use crate::utils;

pub fn run() {
    let test_input_path = "../inputs/day10_test.txt";
    let real_input_path = "../inputs/day10.txt";

    utils::run_solution("Part 1", part1, test_input_path, real_input_path, Some(7));
    utils::run_solution("Part 2", part2, test_input_path, real_input_path, Some(33));
}

pub fn part1(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let mut total_presses = 0;

    for line in input.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        let (target, buttons) = parse_machine(line);
        let min_presses = solve_gaussian_elimination(&target, &buttons);
        if min_presses != i64::MAX {
            total_presses += min_presses;
        }
    }

    total_presses
}

pub fn part2(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let mut total_presses = 0;

    for line in input.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        let (targets, buttons) = parse_machine_part2(line);
        let min_presses = solve_integer_linear_programming(&targets, &buttons);
        total_presses += min_presses;
    }

    total_presses
}

fn parse_machine(line: &str) -> (Vec<bool>, Vec<Vec<bool>>) {
    let s_idx = line.find('[').unwrap();
    let e_idx = line.find(']').unwrap();
    let indicator = &line[s_idx + 1..e_idx];
    let target: Vec<bool> = indicator.chars().map(|c| c == '#').collect();

    let mut buttons = Vec::new();
    let mut pos = e_idx + 1;
    let limit = line.find('{').unwrap_or(line.len());

    while let Some(open) = line[pos..limit].find('(') {
        let open_abs = pos + open;
        if let Some(close) = line[open_abs..limit].find(')') {
            let close_abs = open_abs + close;
            let indices_str = &line[open_abs + 1..close_abs];
            let mut button = vec![false; target.len()];
            for num_str in indices_str.split(',') {
                if let Ok(idx) = num_str.trim().parse::<usize>() {
                    if idx < target.len() {
                        button[idx] = true;
                    }
                }
            }
            buttons.push(button);
            pos = close_abs + 1;
        } else {
            break;
        }
    }

    (target, buttons)
}

fn parse_machine_part2(line: &str) -> (Vec<i64>, Vec<Vec<i64>>) {
    let s_idx = line.find('[').unwrap();
    let e_idx = line.find(']').unwrap();
    let _num_lights = line[s_idx + 1..e_idx].len();

    let jolts_start = line.find('{').unwrap();
    let jolts_end = line.find('}').unwrap();
    let jolts_str = &line[jolts_start + 1..jolts_end];
    let targets: Vec<i64> = jolts_str
        .split(',')
        .map(|s| s.trim().parse().unwrap())
        .collect();

    let mut buttons = Vec::new();
    let mut pos = e_idx + 1;
    while let Some(open) = line[pos..jolts_start].find('(') {
        let open_abs = pos + open;
        if let Some(close) = line[open_abs..jolts_start].find(')') {
            let close_abs = open_abs + close;
            let indices_str = &line[open_abs + 1..close_abs];
            let mut button = vec![0i64; targets.len()];
            for num_str in indices_str.split(',') {
                if let Ok(idx) = num_str.trim().parse::<usize>() {
                    if idx < targets.len() {
                        button[idx] = 1;
                    }
                }
            }
            buttons.push(button);
            pos = close_abs + 1;
        } else {
            break;
        }
    }

    (targets, buttons)
}

fn solve_gaussian_elimination(target: &[bool], buttons: &[Vec<bool>]) -> i64 {
    let num_lights = target.len();
    let num_buttons = buttons.len();

    let mut matrix = vec![vec![false; num_buttons + 1]; num_lights];
    for light in 0..num_lights {
        for button in 0..num_buttons {
            matrix[light][button] = buttons[button][light];
        }
        matrix[light][num_buttons] = target[light];
    }

    let mut pivot = vec![-1i32; num_lights];
    let mut row = 0;
    let mut col = 0;
    while row < num_lights && col < num_buttons {
        let mut pivot_row = None;
        for r in row..num_lights {
            if matrix[r][col] {
                pivot_row = Some(r);
                break;
            }
        }

        if let Some(pr) = pivot_row {
            if pr != row {
                matrix.swap(row, pr);
            }
            pivot[row] = col as i32;

            for r in 0..num_lights {
                if r != row && matrix[r][col] {
                    for c in col..=num_buttons {
                        matrix[r][c] ^= matrix[row][c];
                    }
                }
            }
            row += 1;
        }
        col += 1;
    }

    for r in 0..num_lights {
        let mut all_zero = true;
        for c in 0..num_buttons {
            if matrix[r][c] {
                all_zero = false;
                break;
            }
        }
        if all_zero && matrix[r][num_buttons] {
            return i64::MAX;
        }
    }

    let mut free_vars = Vec::new();
    let mut is_pivot = vec![false; num_buttons];
    for &p in &pivot {
        if p != -1 {
            is_pivot[p as usize] = true;
        }
    }
    for c in 0..num_buttons {
        if !is_pivot[c] {
            free_vars.push(c);
        }
    }

    let mut min_presses = i64::MAX;
    let num_free = free_vars.len().min(15);
    let max_combinations = 1 << num_free;

    let mut solution = vec![false; num_buttons];
    for mask in 0..max_combinations {
        for (i, &var) in free_vars.iter().enumerate().take(15) {
            solution[var] = ((mask >> i) & 1) == 1;
        }

        for r in (0..num_lights).rev() {
            if pivot[r] != -1 {
                let p_col = pivot[r] as usize;
                let mut val = matrix[r][num_buttons];
                for c in p_col + 1..num_buttons {
                    if matrix[r][c] && solution[c] {
                        val ^= true;
                    }
                }
                solution[p_col] = val;
            }
        }

        let presses = solution.iter().filter(|&&x| x).count() as i64;
        if presses < min_presses {
            min_presses = presses;
        }
    }

    min_presses
}

fn solve_integer_linear_programming(targets: &[i64], buttons: &[Vec<i64>]) -> i64 {
    let num_counters = targets.len();
    let num_buttons = buttons.len();

    let mut matrix = vec![vec![0.0; num_buttons + 1]; num_counters];
    for counter in 0..num_counters {
        for button in 0..num_buttons {
            matrix[counter][button] = buttons[button][counter] as f64;
        }
        matrix[counter][num_buttons] = targets[counter] as f64;
    }

    let mut pivot = vec![-1i32; num_counters];
    let mut row = 0;
    let mut col = 0;
    const EPS: f64 = 1e-9;

    while row < num_counters && col < num_buttons {
        let mut pivot_row = None;
        for r in row..num_counters {
            if matrix[r][col].abs() > EPS {
                pivot_row = Some(r);
                break;
            }
        }

        if let Some(pr) = pivot_row {
            matrix.swap(row, pr);
            pivot[row] = col as i32;

            let div = matrix[row][col];
            for c in col..=num_buttons {
                matrix[row][c] /= div;
            }

            for r in 0..num_counters {
                if r != row && matrix[r][col].abs() > EPS {
                    let factor = matrix[r][col];
                    for c in col..=num_buttons {
                        matrix[r][c] -= factor * matrix[row][c];
                    }
                }
            }
            row += 1;
        }
        col += 1;
    }

    let mut free_vars = Vec::new();
    let mut is_pivot = vec![false; num_buttons];
    for &p in &pivot {
        if p != -1 {
            is_pivot[p as usize] = true;
        }
    }
    for c in 0..num_buttons {
        if !is_pivot[c] {
            free_vars.push(c);
        }
    }

    let max_free_value = *targets.iter().max().unwrap_or(&0);
    let mut min_presses = i64::MAX;
    let mut current_solution = vec![0i64; num_buttons];
    let mut test_solution = vec![0i64; num_buttons];

    search_solutions(
        0,
        &free_vars,
        &mut current_solution,
        &mut test_solution,
        &matrix,
        &pivot,
        num_counters,
        num_buttons,
        &mut min_presses,
        max_free_value,
    );

    if min_presses == i64::MAX { 0 } else { min_presses }
}

fn search_solutions(
    free_var_idx: usize,
    free_vars: &[usize],
    current_solution: &mut [i64],
    test_solution: &mut [i64],
    matrix: &[Vec<f64>],
    pivot: &[i32],
    num_counters: usize,
    num_buttons: usize,
    min_presses: &mut i64,
    max_free_value: i64,
) {
    if free_var_idx == free_vars.len() {
        test_solution.copy_from_slice(current_solution);
        let mut valid = true;
        let mut cur_sum = 0;
        for &s in test_solution.iter() {
            cur_sum += s;
        }
        if cur_sum >= *min_presses {
            return;
        }

        for r in (0..num_counters).rev() {
            if pivot[r] != -1 {
                let p_col = pivot[r] as usize;
                let mut val = matrix[r][num_buttons];
                for c in p_col + 1..num_buttons {
                    if matrix[r][c].abs() > 1e-9 {
                        val -= matrix[r][c] * test_solution[c] as f64;
                    }
                }

                if val < -1e-9 || (val - val.round()).abs() > 1e-9 {
                    valid = false;
                    break;
                }
                let rounded = val.round() as i64;
                if rounded < 0 {
                    valid = false;
                    break;
                }
                test_solution[p_col] = rounded;
                cur_sum += rounded;
                if cur_sum >= *min_presses {
                    valid = false;
                    break;
                }
            }
        }

        if valid {
            *min_presses = (*min_presses).min(cur_sum);
        }
        return;
    }

    let var_idx = free_vars[free_var_idx];
    let mut current_sum = 0;
    for &s in current_solution.iter() {
        current_sum += s;
    }
    
    let upper_bound = (max_free_value).min(*min_presses - current_sum);

    for value in 0..=upper_bound {
        current_solution[var_idx] = value;
        search_solutions(
            free_var_idx + 1,
            free_vars,
            current_solution,
            test_solution,
            matrix,
            pivot,
            num_counters,
            num_buttons,
            min_presses,
            max_free_value,
        );
        if *min_presses == 0 {
            return;
        }
    }
    current_solution[var_idx] = 0;
}
