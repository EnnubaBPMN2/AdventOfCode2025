use crate::utils;

pub fn part1(input: &str) -> i64 {
    let input = input.trim();
    let lines: Vec<&[u8]> = input.lines()
        .map(|line| line.trim().as_bytes())
        .filter(|bytes| !bytes.is_empty())
        .collect();

    if lines.is_empty() {
        return 0;
    }

    let rows = lines.len();
    let cols = lines[0].len();
    let mut accessible_count = 0;

    // Directions: N, NE, E, SE, S, SW, W, NW
    let dr = [-1, -1, 0, 1, 1, 1, 0, -1];
    let dc = [0, 1, 1, 1, 0, -1, -1, -1];

    for r in 0..rows {
        for c in 0..cols {
            if lines[r][c] == b'@' {
                let mut neighbor_count = 0;
                for i in 0..8 {
                    let nr = r as i32 + dr[i];
                    let nc = c as i32 + dc[i];

                    if nr >= 0 && nr < rows as i32 && nc >= 0 && nc < cols as i32 {
                        if lines[nr as usize][nc as usize] == b'@' {
                            neighbor_count += 1;
                        }
                    }
                }

                if neighbor_count < 4 {
                    accessible_count += 1;
                }
            }
        }
    }

    accessible_count
}

pub fn part2(input: &str) -> i64 {
    let input = input.trim();
    let mut lines: Vec<Vec<u8>> = input.lines()
        .map(|line| line.trim().as_bytes().to_vec())
        .filter(|bytes| !bytes.is_empty())
        .collect();

    if lines.is_empty() {
        return 0;
    }

    let rows = lines.len();
    let cols = lines[0].len();
    let mut total_removed = 0;

    // Directions: N, NE, E, SE, S, SW, W, NW
    let dr = [-1, -1, 0, 1, 1, 1, 0, -1];
    let dc = [0, 1, 1, 1, 0, -1, -1, -1];

    loop {
        let mut to_remove = Vec::new();

        for r in 0..rows {
            for c in 0..cols {
                if lines[r][c] == b'@' {
                    let mut neighbor_count = 0;
                    for i in 0..8 {
                        let nr = r as i32 + dr[i];
                        let nc = c as i32 + dc[i];

                        if nr >= 0 && nr < rows as i32 && nc >= 0 && nc < cols as i32 {
                            if lines[nr as usize][nc as usize] == b'@' {
                                neighbor_count += 1;
                            }
                        }
                    }

                    if neighbor_count < 4 {
                        to_remove.push((r, c));
                    }
                }
            }
        }

        if to_remove.is_empty() {
            break;
        }

        total_removed += to_remove.len() as i64;
        for (r, c) in to_remove {
            lines[r][c] = b'.';
        }
    }

    total_removed
}

pub fn run() {
    utils::run_solution("Part 1", part1, "../inputs/day04_test.txt", "../inputs/day04.txt", Some(13));
    utils::run_solution("Part 2", part2, "../inputs/day04_test.txt", "../inputs/day04.txt", Some(43));
}
