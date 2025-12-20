package day06

import (
	"adventofcode2025/aocgo/utils"
	"strconv"
	"strings"
)

type Block struct {
	StartCol int
	EndCol   int
}

func parseGrid(input string) [][]byte {
	lines := strings.Split(strings.ReplaceAll(input, "\r\n", "\n"), "\n")
	filteredLines := make([]string, 0)
	maxWidth := 0
	for _, line := range lines {
		if strings.TrimSpace(line) != "" || len(filteredLines) > 0 {
			filteredLines = append(filteredLines, line)
			if len(line) > maxWidth {
				maxWidth = len(line)
			}
		}
	}

	// Remove trailing empty lines
	for len(filteredLines) > 0 && strings.TrimSpace(filteredLines[len(filteredLines)-1]) == "" {
		filteredLines = filteredLines[:len(filteredLines)-1]
	}

	grid := make([][]byte, len(filteredLines))
	for i, line := range filteredLines {
		row := make([]byte, maxWidth)
		for j := 0; j < maxWidth; j++ {
			if j < len(line) {
				row[j] = line[j]
			} else {
				row[j] = ' '
			}
		}
		grid[i] = row
	}
	return grid
}

func findBlocks(grid [][]byte) []Block {
	if len(grid) == 0 {
		return nil
	}
	width := len(grid[0])
	height := len(grid)
	blocks := make([]Block, 0)

	start := -1
	for col := 0; col < width; col++ {
		isEmpty := true
		for row := 0; row < height; row++ {
			if grid[row][col] != ' ' {
				isEmpty = false
				break
			}
		}

		if !isEmpty {
			if start == -1 {
				start = col
			}
		} else {
			if start != -1 {
				blocks = append(blocks, Block{StartCol: start, EndCol: col - 1})
				start = -1
			}
		}
	}
	if start != -1 {
		blocks = append(blocks, Block{StartCol: start, EndCol: width - 1})
	}
	return blocks
}

func Part1(input string) int64 {
	grid := parseGrid(input)
	if len(grid) < 2 {
		return 0
	}
	blocks := findBlocks(grid)
	height := len(grid)
	total := int64(0)

	for _, b := range blocks {
		// Get operator from last row
		op := '+'
		for col := b.StartCol; col <= b.EndCol; col++ {
			char := rune(grid[height-1][col])
			if char == '+' || char == '*' {
				op = char
				break
			}
		}

		// Get numbers from each row above the operator row
		numbers := make([]int64, 0)
		for row := 0; row < height-1; row++ {
			numStr := strings.TrimSpace(string(grid[row][b.StartCol : b.EndCol+1]))
			if numStr != "" {
				val, _ := strconv.ParseInt(numStr, 10, 64)
				numbers = append(numbers, val)
			}
		}

		if len(numbers) > 0 {
			res := numbers[0]
			for i := 1; i < len(numbers); i++ {
				if op == '+' {
					res += numbers[i]
				} else {
					res *= numbers[i]
				}
			}
			total += res
		}
	}

	return total
}

func Part2(input string) int64 {
	grid := parseGrid(input)
	if len(grid) < 2 {
		return 0
	}
	blocks := findBlocks(grid)
	height := len(grid)
	total := int64(0)

	for _, b := range blocks {
		// Get operator from last row
		op := '+'
		for col := b.StartCol; col <= b.EndCol; col++ {
			char := rune(grid[height-1][col])
			if char == '+' || char == '*' {
				op = char
				break
			}
		}

		// Get numbers by reading columns right-to-left
		numbers := make([]int64, 0)
		for col := b.EndCol; col >= b.StartCol; col-- {
			var sb strings.Builder
			for row := 0; row < height-1; row++ {
				if grid[row][col] != ' ' {
					sb.WriteByte(grid[row][col])
				}
			}
			numStr := sb.String()
			if numStr != "" {
				val, _ := strconv.ParseInt(numStr, 10, 64)
				numbers = append(numbers, val)
			}
		}

		if len(numbers) > 0 {
			res := numbers[0]
			for i := 1; i < len(numbers); i++ {
				if op == '+' {
					res += numbers[i]
				} else {
					res *= numbers[i]
				}
			}
			total += res
		}
	}

	return total
}

func Run() {
	testPath := "../inputs/day06_test.txt"
	realPath := "../inputs/day06.txt"

	// Part 1 Answer: 6891729672676
	// Part 2 Answer: 9770311947567
	utils.RunSolution("Part 1", Part1, testPath, realPath, 4277556)
	utils.RunSolution("Part 2", Part2, testPath, realPath, 3263827)
}
