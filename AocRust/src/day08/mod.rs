use crate::utils;
use std::collections::{HashMap, HashSet};

pub fn run() {
    let test_input_path = "../inputs/day08_test.txt";
    let real_input_path = "../inputs/day08.txt";

    utils::run_solution("Part 1", part1, test_input_path, real_input_path, Some(40));
    utils::run_solution("Part 2", part2, test_input_path, real_input_path, Some(25272));
}

pub fn part1(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let lines: Vec<&str> = input.lines().filter(|line| !line.is_empty()).collect();

    if lines.is_empty() {
        return 0;
    }

    // Parse junction box positions
    let mut points = Vec::new();
    for line in lines {
        let parts: Vec<&str> = line.split(',').collect();
        if parts.len() == 3 {
            if let (Ok(x), Ok(y), Ok(z)) = (
                parts[0].parse::<i32>(),
                parts[1].parse::<i32>(),
                parts[2].parse::<i32>(),
            ) {
                points.push((x, y, z));
            }
        }
    }

    let n = points.len();

    // Calculate all pairwise distances
    let mut distances = Vec::new();
    for i in 0..n {
        for j in (i + 1)..n {
            let p1 = points[i];
            let p2 = points[j];
            let dx = (p1.0 - p2.0) as i64;
            let dy = (p1.1 - p2.1) as i64;
            let dz = (p1.2 - p2.2) as i64;
            let dist = ((dx * dx + dy * dy + dz * dz) as f64).sqrt();
            distances.push((dist, i, j));
        }
    }

    // Sort by distance
    distances.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap());

    // Union-Find
    let mut parent: Vec<usize> = (0..n).collect();
    let mut size = vec![1; n];

    fn find(parent: &mut Vec<usize>, x: usize) -> usize {
        if parent[x] != x {
            parent[x] = find(parent, parent[x]);
        }
        parent[x]
    }

    fn union(parent: &mut Vec<usize>, size: &mut Vec<usize>, x: usize, y: usize) {
        let root_x = find(parent, x);
        let root_y = find(parent, y);
        if root_x != root_y {
            if size[root_x] < size[root_y] {
                parent[root_x] = root_y;
                size[root_y] += size[root_x];
            } else {
                parent[root_y] = root_x;
                size[root_x] += size[root_y];
            }
        }
    }

    // Connect the 1000 shortest pairs (or 10 for test)
    let connections_to_make = if n == 20 { 10 } else { 1000 };
    let mut connections_made = 0;

    for (_dist, i, j) in &distances {
        if connections_made >= connections_to_make {
            break;
        }
        union(&mut parent, &mut size, *i, *j);
        connections_made += 1;
    }

    // Find all unique circuits and their sizes
    let mut circuit_sizes = HashMap::new();
    for i in 0..n {
        let root = find(&mut parent, i);
        *circuit_sizes.entry(root).or_insert(0) += 1;
    }

    // Get three largest circuit sizes
    let mut sizes: Vec<i64> = circuit_sizes.values().map(|&s| s as i64).collect();
    sizes.sort_by(|a, b| b.cmp(a));

    if sizes.len() >= 3 {
        sizes[0] * sizes[1] * sizes[2]
    } else if sizes.len() == 2 {
        sizes[0] * sizes[1]
    } else if sizes.len() == 1 {
        sizes[0]
    } else {
        0
    }
}

pub fn part2(input: &str) -> i64 {
    let input = input.replace("\r", "");
    let lines: Vec<&str> = input.lines().filter(|line| !line.is_empty()).collect();

    if lines.is_empty() {
        return 0;
    }

    // Parse junction box positions
    let mut points = Vec::new();
    for line in lines {
        let parts: Vec<&str> = line.split(',').collect();
        if parts.len() == 3 {
            if let (Ok(x), Ok(y), Ok(z)) = (
                parts[0].parse::<i32>(),
                parts[1].parse::<i32>(),
                parts[2].parse::<i32>(),
            ) {
                points.push((x, y, z));
            }
        }
    }

    let n = points.len();

    // Calculate all pairwise distances
    let mut distances = Vec::new();
    for i in 0..n {
        for j in (i + 1)..n {
            let p1 = points[i];
            let p2 = points[j];
            let dx = (p1.0 - p2.0) as i64;
            let dy = (p1.1 - p2.1) as i64;
            let dz = (p1.2 - p2.2) as i64;
            let dist = ((dx * dx + dy * dy + dz * dz) as f64).sqrt();
            distances.push((dist, i, j));
        }
    }

    // Sort by distance
    distances.sort_by(|a, b| a.0.partial_cmp(&b.0).unwrap());

    // Union-Find
    let mut parent: Vec<usize> = (0..n).collect();
    let mut size = vec![1; n];

    fn find(parent: &mut Vec<usize>, x: usize) -> usize {
        if parent[x] != x {
            parent[x] = find(parent, parent[x]);
        }
        parent[x]
    }

    fn union(parent: &mut Vec<usize>, size: &mut Vec<usize>, x: usize, y: usize) -> bool {
        let root_x = find(parent, x);
        let root_y = find(parent, y);
        if root_x != root_y {
            if size[root_x] < size[root_y] {
                parent[root_x] = root_y;
                size[root_y] += size[root_x];
            } else {
                parent[root_y] = root_x;
                size[root_x] += size[root_y];
            }
            true
        } else {
            false
        }
    }

    fn count_circuits(parent: &mut Vec<usize>, n: usize) -> usize {
        let mut roots = HashSet::new();
        for i in 0..n {
            roots.insert(find(parent, i));
        }
        roots.len()
    }

    // Connect pairs until there's only one circuit
    let mut last_i = 0;
    let mut last_j = 0;

    for (_dist, i, j) in &distances {
        if union(&mut parent, &mut size, *i, *j) {
            last_i = *i;
            last_j = *j;
            if count_circuits(&mut parent, n) == 1 {
                break;
            }
        }
    }

    // Multiply X coordinates of last two connected junction boxes
    (points[last_i].0 as i64) * (points[last_j].0 as i64)
}
