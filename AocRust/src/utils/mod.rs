use std::fs;
use std::path::Path;
use std::time::Instant;

/// Reads the entire content of a file as a single string
pub fn read_input(file_path: &str) -> Result<String, std::io::Error> {
    if !Path::new(file_path).exists() {
        return Err(std::io::Error::new(
            std::io::ErrorKind::NotFound,
            format!("Input file not found: {}", file_path),
        ));
    }
    
    let content = fs::read_to_string(file_path)?;
    Ok(content.trim().to_string())
}

/// Reads a file and returns a vector of non-empty lines
#[allow(dead_code)]
pub fn read_lines(file_path: &str) -> Result<Vec<String>, std::io::Error> {
    let content = read_input(file_path)?;
    Ok(content
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|line| line.to_string())
        .collect())
}

/// Runs a test case and compares the result with expected value
pub fn run_test<T: std::fmt::Display + PartialEq>(
    test_name: &str,
    test_func: impl FnOnce() -> T,
    expected: T,
) -> bool {
    print!("Running {}... ", test_name);
    
    let start = Instant::now();
    let result = test_func();
    let elapsed = start.elapsed();
    
    let passed = result == expected;
    
    if passed {
        println!("✓ PASSED (Result: {}) [{:.3}s]", result, elapsed.as_secs_f64());
    } else {
        println!("✗ FAILED (Expected: {}, Got: {}) [{:.3}s]", expected, result, elapsed.as_secs_f64());
    }
    
    passed
}

/// Runs a solution part with both test and real inputs
pub fn run_solution<T: std::fmt::Display>(
    part_name: &str,
    solver: impl Fn(&str) -> T,
    test_input_path: &str,
    real_input_path: &str,
    expected_test_result: Option<T>,
) where
    T: PartialEq,
{
    println!("\n=== {} ===", part_name);
    
    // Run test if expected result is provided
    if let Some(expected) = expected_test_result {
        if Path::new(test_input_path).exists() {
            if let Ok(test_input) = read_input(test_input_path) {
                run_test(
                    &format!("{} (Test)", part_name),
                    || solver(&test_input),
                    expected,
                );
            }
        }
    }
    
    // Run with real input
    if Path::new(real_input_path).exists() {
        match read_input(real_input_path) {
            Ok(real_input) => {
                print!("Running {} (Real Input)... ", part_name);
                let start = Instant::now();
                let result = solver(&real_input);
                let elapsed = start.elapsed();
                println!("Result: {} [{:.3}s]", result, elapsed.as_secs_f64());
            }
            Err(e) => {
                println!("ERROR: {}", e);
            }
        }
    } else {
        println!("⚠ Real input file not found: {}", real_input_path);
        println!("  Please download your puzzle input from https://adventofcode.com/2025/day/X/input");
    }
}
