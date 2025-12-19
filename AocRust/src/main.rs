use std::io::{self, Write};

mod utils;
mod day01;
mod day02;
mod day03;
mod day04;
mod day05;
mod day06;
mod day07;
mod day08;
mod day09;
mod day10;
mod day11;
mod day12;

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
                println!(); // Add blank line after running a day
            }
            // Add more days here as you implement them
            Ok(2) => {
                day02::run();
                println!(); // Add blank line after running a day
            }
            Ok(3) => {
                day03::run();
                println!(); // Add blank line after running a day
            }
            Ok(4) => {
                day04::run();
                println!(); // Add blank line after running a day
            }
            Ok(5) => {
                day05::run();
                println!(); // Add blank line after running a day
            }
            Ok(6) => {
                day06::run();
                println!(); // Add blank line after running a day
            }
            Ok(7) => {
                day07::run();
                println!(); // Add blank line after running a day
            }
            Ok(8) => {
                day08::run();
                println!(); // Add blank line after running a day
            }
            Ok(9) => {
                day09::run();
                println!(); // Add blank line after running a day
            }
            Ok(10) => {
                day10::run();
                println!(); // Add blank line after running a day
            }
            Ok(11) => {
                day11::run();
                println!(); // Add blank line after running a day
            }
            Ok(12) => {
                day12::run();
                println!(); // Add blank line after running a day
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
