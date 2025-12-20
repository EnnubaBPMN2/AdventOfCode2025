# 🐹 Advent of Code 2025 - Go Implementation

This directory contains the Go (Golang) implementation of Advent of Code 2025 solutions.

## 📁 Structure

```
AocGo/
├── go.mod              # Go module file
├── main.go             # Entry point
├── day01/
│   └── solution.go     # Day 1 solution
├── day02/
│   └── solution.go     # Day 2 solution (template)
└── utils/
    ├── input.go        # Input reading utilities
    └── runner.go       # Test runner with timing
```

## 🚀 Running Solutions

### First Time Setup

```powershell
cd AocGo

# Initialize Go modules (automatically downloads dependencies if needed)
go mod tidy
```

### Run a Solution

```powershell
# Run the program
go run main.go

# Enter the day number when prompted (e.g., 1)
```

### Build and Run (Faster for Multiple Runs)

```powershell
# Build the executable
go build -o aoc.exe

# Run it
./aoc.exe
```

### Build for Release (Optimized)

```powershell
# Build with optimizations and smaller binary size
go build -ldflags="-s -w" -o aoc.exe
```

## 🔧 Go Features Used

- **Fast compilation**: Sub-second build times
- **Static typing**: Compile-time type checking
- **Efficient string parsing**: Using `strings.Fields()` and `strconv`
- **Goroutines-ready**: Easy to parallelize future solutions
- **Standard library only**: No external dependencies needed

## 📊 Performance Tips

- Go binaries are already optimized by default
- Use `-ldflags="-s -w"` for smaller binaries (strips debug info)
- For CPU-intensive tasks, Go's goroutines can parallelize work easily
- The `time.Since()` in utils provides accurate timing measurements

## 🆚 Go vs Other Languages in This Project

| Feature | Go | C# | Python | Rust |
|---------|----|----|--------|------|
| Compilation Speed | ⚡ Very Fast | Fast | N/A (Interpreted) | Slow |
| Runtime Speed | 🔥 Fast | Fast | Slow (use PyPy) | 🔥 Fastest |
| Concurrency | Built-in (Goroutines) | async/await | GIL Limited | Complex (ownership) |
| Learning Curve | Low | Medium | Very Low | High |
| Memory Safety | GC | GC | GC | Ownership |

## 📝 Adding New Days

1. Create a new directory: `dayXX/`
2. Create `solution.go`:

```go
package dayXX

import "adventofcode2025/aocgo/utils"

func Part1(input string) int {
    // Your solution here
    return 0
}

func Part2(input string) int {
    // Your solution here
    return 0
}

func Run() {
    testPath := "../inputs/dayXX_test.txt"
    realPath := "../inputs/dayXX.txt"
    
    utils.RunSolution("Part 1", Part1, testPath, realPath, expectedTest1)
    utils.RunSolution("Part 2", Part2, testPath, realPath, expectedTest2)
}
```

3. Update `main.go`:

```go
import "adventofcode2025/aocgo/dayXX"

// In switch statement:
case XX:
    fmt.Println("\n📅 Day XX: Problem Name")
    dayXX.Run()
```

## 📚 Resources

- [Official Go Documentation](https://go.dev/doc/)
- [Tour of Go](https://go.dev/tour/)
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://go.dev/doc/effective_go)
