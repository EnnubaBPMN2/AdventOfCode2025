package day07

import (
	"adventofcode2025/aocgo/utils"
	"strings"
)

func parseGrid(input string) ([][]byte, int, int) {
	lines := strings.Split(strings.ReplaceAll(input, "\r\n", "\n"), "\n")
	grid := make([][]byte, 0)
	sr, sc := -1, -1
	for r, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		if sc == -1 {
			if idx := strings.Index(line, "S"); idx != -1 {
				sr, sc = r, idx
			}
		}
		grid = append(grid, []byte(line))
	}
	return grid, sr, sc
}

func Part1(input string) int64 {
	grid, sr, sc := parseGrid(input)
	if sr == -1 {
		return 0
	}

	height := len(grid)
	width := len(grid[0])
	active := make([]bool, width)
	active[sc] = true
	splitCount := int64(0)

	// We'll track which splitters in the current row were already processed
	// to ensure we only increment count once per splitter per row.
	// Actually, the problem says "How many times will THE beam be split",
	// and if multiple paths reach the same splitter, it's still just one splitter location.
	// Rust implementation counts it every time it's encountered by ANY beam.
	// Let's re-read: "if a tachyon beam encounters a splitter (^)... a new tachyon beam continues
	// from the immediate left and from the immediate right".
	// The example says "split a total of 21 times".

	for r := sr + 1; r < height; r++ {
		nextActive := make([]bool, width)
		for c := 0; c < width; c++ {
			if !active[c] {
				continue
			}

			cell := grid[r][c]
			if cell == '^' {
				splitCount++
				if c > 0 {
					nextActive[c-1] = true
				}
				if c+1 < width {
					nextActive[c+1] = true
				}
			} else {
				// Empty space or whatever, beam continues down
				nextActive[c] = true
			}
		}
		active = nextActive
	}

	return splitCount
}

func Part2(input string) int64 {
	grid, sr, sc := parseGrid(input)
	if sr == -1 {
		return 0
	}

	height := len(grid)
	width := len(grid[0])
	paths := make([]int64, width)
	paths[sc] = 1

	for r := sr + 1; r < height; r++ {
		nextPaths := make([]int64, width)
		for c := 0; c < width; c++ {
			count := paths[c]
			if count == 0 {
				continue
			}

			cell := grid[r][c]
			if cell == '^' {
				// Quantum split: timeline splits into two
				if c > 0 {
					nextPaths[c-1] += count
				}
				if c+1 < width {
					nextPaths[c+1] += count
				}
			} else {
				// Continue down in current timeline
				nextPaths[c] += count
			}
		}
		paths = nextPaths
	}

	totalPaths := int64(0)
	for _, count := range paths {
		totalPaths += count
	}
	return totalPaths
}

func Run() {
	testPath := "../inputs/day07_test.txt"
	realPath := "../inputs/day07.txt"

	utils.RunSolution("Part 1", Part1, testPath, realPath, 21)
	utils.RunSolution("Part 2", Part2, testPath, realPath, 40)
}
