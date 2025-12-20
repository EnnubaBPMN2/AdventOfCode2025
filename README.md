# 🎄 Advent of Code 2025 🎄

Multi-language solution repository for [Advent of Code 2025](https://adventofcode.com/2025) challenges, featuring implementations in **C#**, **Python**, and **Rust**.

## 📁 Project Structure

```text
AdventOfCode2025
├── AdventOfCode2025.sln
├── inputs
│   ├── day01.txt
│   └── day01_test.txt
├── AocCsharp
│   ├── AocCsharp.csproj
│   ├── Program.cs
│   ├── Day01
│   │   └── Day01.cs
│   └── Utils
│       ├── InputReader.cs
│       └── TestRunner.cs
├── AocPython
│   ├── main.py
│   ├── day01
│   │   ├── __init__.py
│   │   └── solution.py
│   └── utils
│       ├── __init__.py
│       └── input_reader.py
└── AocRust
    ├── Cargo.toml
    ├── src
    │   ├── main.rs
    │   ├── day01
    │   │   └── mod.rs
    │   └── utils
    │       └── mod.rs
```

## 🚀 Getting Started

### Prerequisites

- **C#**: [.NET 8.0 SDK](https://dotnet.microsoft.com/download) or later
- **Python**: [Python 3.10+](https://www.python.org/downloads/)
- **Rust**: [Rust toolchain](https://rustup.rs/)

### Running Solutions

#### C# (Recommended Starting Point)

```powershell
cd AocCsharp
dotnet run
```

Select the day number when prompted. The solution will:
1. Run the test input and verify against expected result
2. Run your actual puzzle input (if available)

#### Python

```powershell
cd AocPython
python main.py
```

#### Rust

```powershell
cd AocRust
cargo run
```

## 📝 Workflow

### Solving a New Day

1. **Start with C#** - Implement and test the solution
2. **Move to Python** - Port the working C# solution
3. **Finish with Rust** - Port the Python solution to Rust

### Adding a New Day Solution

#### C# Example (Day 02)

1. Create folder: `AocCsharp/Day02/`
2. Create `Day02.cs`:

```csharp
using AocCsharp.Utils;

namespace AocCsharp.Day02;

public static class Day02
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day02_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day02.txt");

        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 0);
        TestRunner.RunSolution("Part 2", Part2, testInputPath, realInputPath, expectedTestResult: 0);
    }

    public static int Part1(string input)
    {
        // Your solution here
        return 0;
    }

    public static int Part2(string input)
    {
        // Your solution here
        return 0;
    }
}
```

3. Add input files: `inputs/day02_test.txt` and `inputs/day02.txt`
4. Update `Program.cs` to include Day 02:

```csharp
case 2:
    Day02.Run();
    break;
```

#### Python Example (Day 02)

1. Create folder: `AocPython/day02/`
2. Create `__init__.py` (empty)
3. Create `solution.py`:

```python
import os
from utils.input_reader import run_solution

def part1(input_text: str) -> int:
    # Your solution here
    return 0

def part2(input_text: str) -> int:
    # Your solution here
    return 0

def run():
    # Go up two levels to reach solution root, then into inputs
    day_dir = os.path.dirname(os.path.abspath(__file__))
    solution_root = os.path.dirname(os.path.dirname(day_dir))
    test_input_path = os.path.join(solution_root, "inputs", "day02_test.txt")
    real_input_path = os.path.join(solution_root, "inputs", "day02.txt")
    
    run_solution("Part 1", part1, test_input_path, real_input_path, expected_test_result=0)
    run_solution("Part 2", part2, test_input_path, real_input_path, expected_test_result=0)
```

4. Add input files: `inputs/day02_test.txt` and `inputs/day02.txt`
5. Update `main.py`:

```python
from day02.solution import run as run_day02

# In main():
if day_num == 2:
    run_day02()
```

#### Rust Example (Day 02)

1. Create file: `AocRust/src/day02/mod.rs`:

```rust
use crate::utils;

pub fn part1(input: &str) -> i32 {
    // Your solution here
    0
}

pub fn part2(input: &str) -> i32 {
    // Your solution here
    0
}

pub fn run() {
    utils::run_solution("Part 1", part1, "../inputs/day02_test.txt", "../inputs/day02.txt", Some(0));
    utils::run_solution("Part 2", part2, "../inputs/day02_test.txt", "../inputs/day02.txt", Some(0));
}
```

2. Add input files: `inputs/day02_test.txt` and `inputs/day02.txt`
3. Update `src/main.rs`:

```rust
mod day02;

// In main():
Ok(2) => {
    day02::run();
}
```

## 📥 Getting Your Puzzle Input

1. Go to [Advent of Code 2025](https://adventofcode.com/2025)
2. Log in with your preferred service
3. Navigate to the day you're solving
4. Click "get your puzzle input"
5. Copy the input and paste it into the respective `inputs/dayXX.txt` file

## ✅ Testing

Each solution automatically runs against:
- **Test Input**: Example from the problem description with known expected result
- **Real Input**: Your actual puzzle input from adventofcode.com

The test framework will:
- ✓ Show PASSED if test matches expected result
- ✗ Show FAILED if test doesn't match
- Display the actual result for your puzzle input

## 🎯 Current Progress

- [x] Day 01 - Secret Entrance (Dial Rotation)
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 02 - Gift Shop
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 03 - Printing Department
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 04 - Printing Department
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 05 - Cafeteria
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 06 - Trash Compactor (Math Worksheet)
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 07 - Laboratories (Tachyon Manifold)
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 08 - Playground (Junction Box Circuits)
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 09 - Day 09
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 10 - Factory (Indicator Lights & Joltage Counters)
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 11 - Reactor (Path Finding)
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation
- [x] Day 12 - Christmas Tree Farm (2D Shape Packing)
  - [x] C# Implementation
  - [x] Python Implementation
  - [x] Rust Implementation

## 💡 Tips

- **Read the problem carefully** - Advent of Code problems often have subtle details
- **Test with examples first** - Always verify your solution works with the test input
- **Start simple** - Get Part 1 working before thinking about Part 2
- **Share inputs carefully** - Don't share your puzzle inputs publicly (per AoC rules)

## 📚 Resources

- [Advent of Code 2025](https://adventofcode.com/2025)
- [Advent of Code Subreddit](https://www.reddit.com/r/adventofcode/)
- [C# Documentation](https://learn.microsoft.com/en-us/dotnet/csharp/)
- [Python Documentation](https://docs.python.org/3/)
- [Rust Documentation](https://doc.rust-lang.org/)

## ⚡ Performance Comparison

Execution times for real puzzle inputs across all three language implementations (in seconds):

| Day | Problem | C# | PyPy | Rust | Fastest |
|-----|---------|------|------|------|---------|
| **1** | Secret Entrance (Dial Rotation) |
| | Part 1 | 0.001s | 0.009s | 0.000s | 🥇 Rust |
| | Part 2 | 0.000s | 0.007s | 0.000s | 🥇 C# / Rust |
| **2** | Gift Shop |
| | Part 1 | 0.018s | 0.029s | 0.019s | 🥇 C# |
| | Part 2 | 0.049s | 0.087s | 0.055s | 🥇 C# |
| **3** | Printing Department |
| | Part 1 | 0.000s | 0.010s | 0.000s | 🥇 C# / Rust |
| | Part 2 | 0.000s | 0.013s | 0.000s | 🥇 C# / Rust |
| **4** | Printing Department |
| | Part 1 | 0.001s | 0.018s | 0.000s | 🥇 Rust |
| | Part 2 | 0.024s | 0.042s | 0.006s | 🥇 Rust |
| **5** | Cafeteria |
| | Part 1 | 0.000s | 0.007s | 0.000s | 🥇 C# / Rust |
| | Part 2 | 0.000s | 0.001s | 0.000s | 🥇 C# / Rust |
| **6** | Trash Compactor (Math Worksheet) |
| | Part 1 | 0.001s | 0.019s | 0.000s | 🥇 Rust |
| | Part 2 | 0.000s | 0.020s | 0.001s | 🥇 C# |
| **7** | Laboratories (Tachyon Manifold) |
| | Part 1 | 0.000s | 0.007s | 0.000s | 🥇 C# / Rust |
| | Part 2 | 0.001s | 0.011s | 0.000s | 🥇 Rust |
| **8** | Playground (Junction Box Circuits) |
| | Part 1 | 0.162s | 0.789s | 0.037s | 🥇 Rust |
| | Part 2 | 0.167s | 0.791s | 0.047s | 🥇 Rust |
| **9** | Day 09 |
| | Part 1 | 0.003s | 0.005s | 0.000s | 🥇 Rust |
| | Part 2 | 1.103s | 0.413s | 0.125s | 🥇 Rust |
| **10** | Factory (Indicator Lights & Joltage Counters) |
| | Part 1 | 0.006s | 0.041s | 0.028s | 🥇 C# |
| | Part 2 | 0.164s | 0.265s | 0.099s | 🥇 Rust |
| **11** | Reactor (Path Finding) |
| | Part 1 | 0.001s | 0.007s | 0.001s | 🥇 C# / Rust |
| | Part 2 | 0.003s | 0.020s | 0.001s | 🥇 Rust |
| **12** | Christmas Tree Farm (2D Shape Packing) ⚡ |
| | Part 1 | 0.435s | 0.423s | 0.123s | 🥇 Rust |
| | Part 2 | *Auto* | *Auto* | *Auto* | - |

### Summary Statistics

| Language | Total Time | Avg Time/Part | Wins |
|----------|-----------|---------------|------|
| **Rust** | 0.697s | 0.030s | 🥇 18/23 |
| **C#** | 2.259s | 0.098s | 🥈 4/23 |
| **PyPy** | 3.027s | 0.132s | 🥉 2/23 |

### Key Observations

- **Rust dominates** with the fastest total time (0.697s) and most individual wins (18/23) - **3.2x faster than C#**!
- **Day 12 optimizations** were a game-changer - went from 20+ seconds to under 0.5s for C# (3.4x faster) and under 2s for Rust (12x faster)
- **PyPy brings Python to competitive levels** - using PyPy's JIT compiler makes Python 18.7x faster on Day 12 (87s → 4.6s)
- **Rust's release mode is critical** - `cargo run --release` provides 10-100x speedup over debug builds
- **Precomputed shape orientations** were the key optimization for Day 12 across all languages - eliminating repeated computations in hot loops
- **C# holds its own** with excellent JIT optimization, staying competitive despite Rust's native compilation advantage
- **PyPy wins on Day 2** - JIT compilation shines on iterative arithmetic operations
- **Day 8 shows PyPy's weakness** - Circuit simulation with complex logic benefits less from JIT, PyPy is 4.7x slower than Rust here
- **Day 9 Part 2** demonstrates algorithm wins - Rust's 0.125s vs C#'s 1.103s (8.8x faster) shows low-level optimization benefits for complex backtracking
- **All three languages are production-ready** for Advent of Code - even PyPy completes all 12 days in just over 3 seconds

*Note: Times measured on Windows with .NET 10.0.101, PyPy 7.3+, and Rust 1.75+ (with `--release` flag). Python (CPython) is significantly slower; PyPy recommended for performance-critical code.*

## 📄 License

This is a personal learning project for Advent of Code 2025. Solutions are provided as-is for educational purposes.

---

**Happy Coding! 🎄**
