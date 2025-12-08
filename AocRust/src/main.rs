use std::io::{self, Write};

mod utils;
mod day01;
mod day02;
mod day03;
mod day04;
mod day05;
mod day06;
mod day07;

fn main() {
    println!("\n{}", "=".repeat(50));
    println!("🎄 Advent of Code 2025 - Rust Solutions 🎄");
    println!("{}\n", "=".repeat(50));

    loop {
        print!("Select a day (1-25) or 0 to exit: ");
        io::stdout().flush().unwrap();

        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();

        match input.trim().parse::<u32>() {
            Ok(0) => {
                println!("\n🎄 Happy Coding! 🎄\n");
                break;
            }
            Ok(1) => {
                day01::run();
            }
            // Add more days here as you implement them
            Ok(2) => {
                day02::run();
            }
            Ok(3) => {
                day03::run();
            }
            Ok(4) => {
                day04::run();
            }
            Ok(5) => {
                day05::run();
            }
            Ok(6) => {
                day06::run();
            }
            Ok(7) => {
                day07::run();
            }
            Ok(day) => {
                println!("\n⚠ Day {} not implemented yet!\n", day);
            }
            Err(_) => {
                println!("Invalid input. Please enter a number.\n");
            }
        }
    }
}
