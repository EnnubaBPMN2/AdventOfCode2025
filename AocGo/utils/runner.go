package utils

import (
	"fmt"
	"time"
)

// SolutionFunc is a function that takes input and returns an integer result
type SolutionFunc func(string) int64

// RunSolution runs a solution with test and real input, timing the execution
func RunSolution(partName string, solver SolutionFunc, testPath string, realPath string, expectedTest int64) {
	fmt.Printf("\n=== %s ===\n", partName)

	// Run test input
	testInput, err := ReadInput(testPath)
	if err != nil {
		fmt.Printf("❌ Failed to read test input: %v\n", err)
		return
	}

	start := time.Now()
	testResult := solver(testInput)
	testDuration := time.Since(start)

	if testResult == expectedTest {
		fmt.Printf("✓ Test PASSED: %d (expected %d) in %v\n", testResult, expectedTest, testDuration)
	} else {
		fmt.Printf("✗ Test FAILED: got %d, expected %d\n", testResult, expectedTest)
		return
	}

	// Run real input
	realInput, err := ReadInput(realPath)
	if err != nil {
		fmt.Printf("⚠ Real input not found: %v\n", err)
		return
	}

	start = time.Now()
	realResult := solver(realInput)
	realDuration := time.Since(start)

	fmt.Printf("→ Real Answer: %d in %v\n", realResult, realDuration)
}
