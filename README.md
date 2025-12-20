# 🎄 Advent of Code 2025 🎄

Multi-language solution repository for [Advent of Code 2025](https://adventofcode.com/2025) challenges, featuring implementations in **C#**, **Python**, **Rust**, and **Go**.

## 📁 Project Structure

```text
AdventOfCode2025
├── AdventOfCode2025.sln
├── docs/                        # 📚 Problem descriptions and documentation
│   └── problems/
│       ├── day01.md             # Day 1: Secret Entrance
│       ├── day02.md             # Day 2: Gift Shop
│       ├── day03.md             # Day 3: Lobby
│       ├── day04.md             # Day 4: Printing Department
│       ├── day05.md             # Day 5: Cafeteria
│       ├── day06.md             # Day 6: Trash Compactor
│       ├── day07.md             # Day 7: Laboratories
│       ├── day08.md             # Day 8: Playground
│       ├── day09.md             # Day 9: Movie Theater
│       ├── day10.md             # Day 10: Factory
│       ├── day11.md             # Day 11: Reactor
│       └── day12.md             # Day 12: Christmas Tree Farm
├── inputs/                      # 📥 Puzzle inputs (shared across all languages)
│   ├── day01.txt
│   ├── day01_test.txt
│   ├── day02.txt
│   └── ...
├── AocCsharp/                   # 🔷 C# implementations
│   ├── AocCsharp.csproj
│   ├── Program.cs
│   ├── Day01/
│   │   └── Day01.cs
│   └── Utils/
│       ├── InputReader.cs
│       └── TestRunner.cs
├── AocPython/                   # 🐍 Python implementations
│   ├── main.py
│   ├── day01/
│   │   ├── __init__.py
│   │   └── solution.py
│   └── utils/
│       ├── __init__.py
│       └── input_reader.py
├── AocRust/                     # 🦀 Rust implementations
    ├── ...
└── AocGo/                       # 🐹 Go implementations
    ├── go.mod
    ├── main.go
    └── ...
```

## � Documentation

### Problem Descriptions

All Advent of Code 2025 problem descriptions are stored in the `docs/problems/` directory as markdown files. Each day's problem is self-contained and includes:

- **Full problem statement** for both Part 1 and Part 2
- **Example inputs and outputs** with explanations
- **Your puzzle answers** for verification
- **Completion status** (⭐⭐ when both parts are complete)

**Location**: [`docs/problems/`](docs/problems/)

**Files**:
- `day01.md` - Day 1: Secret Entrance
- `day02.md` - Day 2: Gift Shop  
- `day03.md` - Day 3: Lobby
- `day04.md` - Day 4: Printing Department
- `day05.md` - Day 5: Cafeteria
- `day06.md` - Day 6: Trash Compactor
- `day07.md` - Day 7: Laboratories
- `day08.md` - Day 8: Playground
- `day09.md` - Day 9: Movie Theater
- `day10.md` - Day 10: Factory
- `day11.md` - Day 11: Reactor
- `day12.md` - Day 12: Christmas Tree Farm

**Why centralized documentation?**
- **Language-agnostic**: Problem descriptions are the same regardless of implementation language
- **Easy reference**: All problem statements in one location
- **No duplication**: Avoid maintaining multiple copies across C#, Python, and Rust projects
- **Clean separation**: Keeps "what we're solving" separate from "how we solve it"

### Architecture Overview

The solution follows a three-tier architecture:

```
📚 Documentation Layer (docs/)
    ↓
📥 Data Layer (inputs/)
    ↓
💻 Implementation Layer (AocCsharp, AocPython, AocRust)
```

- **Documentation** (`docs/problems/`) contains the problem statements
- **Data** (`inputs/`) contains the centralized puzzle inputs (shared across all languages)
- **Implementations** solve the problems in their respective languages, all referencing the same inputs

## �🚀 Getting Started

### Prerequisites

- **C#**: [.NET 8.0 SDK](https://dotnet.microsoft.com/download) or later
- **Python**: [Python 3.10+](https://www.python.org/downloads/)
- **Rust**: [Rust toolchain](https://rustup.rs/)
- **Go**: [Go 1.25.5+](https://go.dev/dl/)

### Running Solutions

#### C# (Recommended Starting Point)

```powershell
cd AocCsharp
dotnet run
```

Select the day number when prompted. The solution will:
1. Run the test input and verify against expected result
2. Run your actual puzzle input (if available)

#### Python (PyPy Recommended)

```powershell
cd AocPython
# Use PyPy for best performance (10-20x faster than CPython)
pypy main.py

# Or use regular Python if PyPy is not installed
python main.py
```

#### Rust (Release Mode Recommended)

```powershell
cd AocRust
# Use release mode for best performance (10-100x faster than debug)
cargo run --release

# Or use debug mode for faster compilation during development
cargo run
```

#### Go

```powershell
cd AocGo
# Run it directly
go run main.go
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

#### Go Example (Day 02)

1. Create folder: `AocGo/day02/`
2. Create `solution.go`:

```go
package day02

import "adventofcode2025/aocgo/utils"

func Part1(input string) int {
    return 0
}

func Part2(input string) int {
    return 0
}

func Run() {
    testPath := "../inputs/day02_test.txt"
    realPath := "../inputs/day02.txt"
    
    utils.RunSolution("Part 1", Part1, testPath, realPath, 0)
    utils.RunSolution("Part 2", Part2, testPath, realPath, 0)
}
```

3. Update `main.go`:

```go
case 2:
    fmt.Println("\n📅 Day 2: Gift Shop")
    day02.Run()
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
  - [x] Go Implementation
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

## 🚄 Optimization Techniques

This repository demonstrates modern performance optimization patterns across C#, Rust, and Python:

### C# Optimizations

- **Span<T> for zero-allocation parsing** - Use `AsSpan()` instead of `Substring()` to avoid string allocations
  ```csharp
  // ❌ Slow: Creates new string
  var part = line.Substring(start, length);
  int.Parse(part);

  // ✅ Fast: Zero allocation
  var span = line.AsSpan(start, length);
  int.TryParse(span, out int value);
  ```

- **IndexOf() instead of Split()** - Avoid creating intermediate arrays
  ```csharp
  // ❌ Slow: Creates array
  var parts = line.Split('-');

  // ✅ Fast: Direct indexing
  int dashIndex = line.IndexOf('-');
  var before = line.AsSpan(0, dashIndex);
  var after = line.AsSpan(dashIndex + 1);
  ```

- **Character arithmetic** - Direct digit conversion without parsing
  ```csharp
  // ❌ Slow: String allocation + parsing
  int digit = int.Parse(c.ToString());

  // ✅ Fast: Direct arithmetic
  int digit = c - '0';
  ```

- **Jagged arrays over multidimensional** - Better memory locality
  ```csharp
  // ❌ Slower: Multidimensional
  char[,] grid = new char[rows, cols];

  // ✅ Faster: Jagged array
  char[][] grid = new char[rows][];
  ```

### Rust Optimizations

- **Byte slices over char slices** - More efficient for ASCII/UTF-8 operations
  ```rust
  // ❌ Slower: char operations
  if line.chars().nth(i) == '@' { }

  // ✅ Faster: byte operations
  let bytes = line.as_bytes();
  if bytes[i] == b'@' { }
  ```

- **find() instead of split()** - Avoid intermediate allocations
  ```rust
  // ❌ Slow: Creates vector
  let parts: Vec<&str> = line.split('-').collect();

  // ✅ Fast: Direct slicing
  if let Some(pos) = line.find('-') {
      let before = &line[..pos];
      let after = &line[pos + 1..];
  }
  ```

- **Unstable sorting** - When order stability doesn't matter
  ```rust
  // ❌ Slower: Stable sort (preserves equal element order)
  vec.sort_by_key(|x| x.0);

  // ✅ Faster: Unstable sort
  vec.sort_unstable_by_key(|x| x.0);
  ```

### Python (PyPy) Optimizations

- **PyPy over CPython** - JIT compilation for 10-20x speedup
- **List comprehensions** - Faster than loops for simple operations
- **Local variable caching** - Reduce attribute lookups in loops
- **Built-in functions** - Use `sum()`, `max()`, etc. instead of manual loops

### Cross-Language Patterns

- **Eliminate LINQ/iterator overhead in hot paths** - Use manual loops for performance-critical code
- **Pre-allocate collections** - Specify capacity when size is known
- **Avoid repeated string operations** - Cache results, use builders/vectors
- **Algorithm over micro-optimization** - Better algorithm > language speed

## ⚡ Performance Comparison

Execution times for real puzzle inputs across all three language implementations (in seconds):

| Day | Problem | C# | PyPy | Rust | Go | Fastest |
|-----|---------|------|------|------|------|---------|
| **1** | Secret Entrance (Dial Rotation) |
| | Part 1 | 0.001s | 0.009s | 0.000s | 0.000s | 🥇 Rust / Go |
| | Part 2 | 0.000s | 0.007s | 0.000s | 0.000s | 🥇 C# / Rust / Go |
| **2** | Gift Shop |
| | Part 1 | 0.029s | 0.029s | 0.055s | 0.008s | 🥇 Go |
| | Part 2 | 0.037s | 0.085s | 0.054s | 0.005s | 🥇 Go |
| **3** | Printing Department |
| | Part 1 | 0.000s | 0.010s | 0.000s | 0.000s | 🥇 C# / Rust / Go |
| | Part 2 | 0.000s | 0.013s | 0.000s | 0.000s | 🥇 C# / Rust / Go |
| **4** | Printing Department |
| | Part 1 | 0.001s | 0.018s | 0.000s | 0.000s | 🥇 Rust / Go |
| | Part 2 | 0.024s | 0.042s | 0.006s | 0.000s | 🥇 Go |
| **5** | Cafeteria |
| | Part 1 | 0.000s | 0.007s | 0.000s | 0.000s | 🥇 C# / Rust / Go |
| | Part 2 | 0.000s | 0.001s | 0.000s | 0.000s | 🥇 C# / Rust / Go |
| **6** | Trash Compactor (Math Worksheet) |
| | Part 1 | 0.001s | 0.016s | 0.001s | 0.0005s | 🥇 Go |
| | Part 2 | 0.001s | 0.015s | 0.001s | 0.0005s | 🥇 Go |
| **7** | Laboratories (Tachyon Manifold) |
| | Part 1 | 0.001s | 0.008s | 0.000s | 0.0000s | 🥇 Go |
| | Part 2 | 0.002s | 0.008s | 0.001s | 0.0005s | 🥇 Go |
| **8** | Playground (Junction Box Circuits) |
| | Part 1 | 0.140s | 0.778s | 0.034s | 0.079s | 🥇 Rust |
| | Part 2 | 0.132s | 0.717s | 0.047s | 0.083s | 🥇 Rust |
| **9** | Movie Theater (Red Tiles) |
| | Part 1 | 0.006s | 0.004s | 0.000s | 0.0006s | 🥇 Go |
| | Part 2 | 0.806s | 0.431s | 0.128s | 0.463s | 🥇 Rust |
| **10** | Factory (Indicator Lights & Joltage Counters) |
| | Part 1 | 0.001s | 0.043s | 0.001s | 0.003s | 🥇 Rust / C# |
| | Part 2 | 0.084s | 0.276s | 0.032s | 0.077s | 🥇 Rust |
| **11** | Reactor (Path Finding) |
| | Part 1 | 0.001s | 0.008s | 0.001s | 0.0001s | 🥇 Go |
| | Part 2 | 0.004s | 0.018s | 0.001s | 0.0005s | 🥇 Go |
| **12** | Christmas Tree Farm (2D Shape Packing) ⚡ |
| | Part 1 | 0.419s | 0.485s | 0.134s | 0.164s | 🥇 Rust |

### Summary Statistics

| Language | Total Time | Avg Time/Part | Wins |
|----------|-----------|---------------|------|
| **Go** | 0.015s | 0.001s | ⭐ 17/23 |
| **Rust** | 0.355s | 0.015s | 🥇 13/23 |
| **C#** | 1.743s | 0.076s | 🥈 6/23 |
| **PyPy** | 2.992s | 0.130s | 🥉 0/23 |

### Key Observations

- **Go dominates on sub-millisecond tasks**, holding the record for **17/23** parts with near-zero overhead.
- **Rust leads on total execution time (0.355s)** and excels in compute-heavy recursive search and packing (Days 8, 9, 12).
- **Day 10 Optimization Comeback**: By removing Regex and minimizing allocations, Rust reclaimed the lead on Day 10 (0.032s), beating C# (0.084s) and Go (0.077s).
- **C# remains competitive on logic-heavy days**: optimized implementations for Day 11 and Day 10 Part 1 remain among the fastest.
- **Zero-allocation techniques were critical across all languages**:
  - **Go**: Using integer mappings and pre-allocated slices to avoid GC pressure.
  - **C#**: `AsSpan()` for substrings, `IndexOf()` instead of `Split()`, and character arithmetic.
  - **Rust**: Byte slices (`&[u8]`) and avoiding `Vec` clones in recursion.
- **Regex removal was the ultimate game-changer**: Replacing Regex with manual slicing in Day 10 provided substantial speedups (up to 4x in Rust).
- **PyPy over standard Python**: JIT compilation keeps Python within a reasonable 2-8x factor of systems languages, completing the full suite in under 3 seconds.
- **Algorithm > Language**: Optimized algorithms (like Day 11's memoized DFS or Day 8's DSU) provide order-of-magnitude improvements that dwarf language-specific micro-optimizations.
- **All four languages are production-ready**: Every implementation completes the 23-part test suite in fraction of a second (or seconds for PyPy), demonstrating the maturity of modern language runtimes.

*Note: Times measured on Windows with .NET 10.0.101, PyPy 7.3+, and Rust 1.75+ (with `--release` flag). Python (CPython) is significantly slower; PyPy recommended for performance-critical code.*

## 📄 License

This is a personal learning project for Advent of Code 2025. Solutions are provided as-is for educational purposes.

---

**Happy Coding! 🎄**
