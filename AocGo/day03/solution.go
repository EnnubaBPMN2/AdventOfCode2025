package day03

import (
	"adventofcode2025/aocgo/utils"
	"strings"
)

// getLargestSubsequence finds the largest subsequence of length k using a monotonic stack approach
func getLargestSubsequence(s string, k int) int64 {
	if len(s) < k {
		return 0
	}

	stack := make([]byte, 0, k)
	n := len(s)

	for i := 0; i < n; i++ {
		digit := s[i]
		remaining := n - 1 - i

		// While stack is not empty, current digit is larger than top of stack,
		// and we have enough remaining digits to still reach length k
		for len(stack) > 0 && digit > stack[len(stack)-1] && len(stack)+remaining >= k {
			stack = stack[:len(stack)-1]
		}

		if len(stack) < k {
			stack = append(stack, digit)
		}
	}

	// Construct result
	var result int64
	for _, digit := range stack {
		result = result*10 + int64(digit-'0')
	}
	return result
}

func Part1(input string) int64 {
	lines := strings.Split(strings.TrimSpace(input), "\n")
	var total int64

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		total += getLargestSubsequence(line, 2)
	}

	return total
}

func Part2(input string) int64 {
	lines := strings.Split(strings.TrimSpace(input), "\n")
	var total int64

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		total += getLargestSubsequence(line, 12)
	}

	return total
}

func Run() {
	testPath := "../inputs/day03_test.txt"
	realPath := "../inputs/day03.txt"

	// Part 1 Test expect: 357
	// Part 2 Test expect: 3121910778619
	utils.RunSolution("Part 1", Part1, testPath, realPath, 357)
	utils.RunSolution("Part 2", Part2, testPath, realPath, 3121910778619)
}
