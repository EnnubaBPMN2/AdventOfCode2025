package day04

import (
	"adventofcode2025/aocgo/utils"
	"strings"
)

type Point struct {
	r, c int
}

var dr = []int{-1, -1, 0, 1, 1, 1, 0, -1}
var dc = []int{0, 1, 1, 1, 0, -1, -1, -1}

func parseGrid(input string) [][]byte {
	lines := strings.Split(strings.TrimSpace(input), "\n")
	grid := make([][]byte, 0, len(lines))
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		grid = append(grid, []byte(line))
	}
	return grid
}

func countNeighbors(grid [][]byte, r, c int) int {
	rows := len(grid)
	cols := len(grid[0])
	count := 0
	for i := 0; i < 8; i++ {
		nr, nc := r+dr[i], c+dc[i]
		if nr >= 0 && nr < rows && nc >= 0 && nc < cols {
			if grid[nr][nc] == '@' {
				count++
			}
		}
	}
	return count
}

func Part1(input string) int64 {
	grid := parseGrid(input)
	if len(grid) == 0 {
		return 0
	}

	rows := len(grid)
	cols := len(grid[0])
	accessible := 0

	for r := 0; r < rows; r++ {
		for c := 0; c < cols; c++ {
			if grid[r][c] == '@' {
				if countNeighbors(grid, r, c) < 4 {
					accessible++
				}
			}
		}
	}

	return int64(accessible)
}

func Part2(input string) int64 {
	grid := parseGrid(input)
	if len(grid) == 0 {
		return 0
	}

	rows := len(grid)
	cols := len(grid[0])

	// Initialize neighbor counts
	neighborCounts := make([][]int, rows)
	for i := range neighborCounts {
		neighborCounts[i] = make([]int, cols)
	}

	queue := make([]Point, 0)

	for r := 0; r < rows; r++ {
		for c := 0; c < cols; c++ {
			if grid[r][c] == '@' {
				count := countNeighbors(grid, r, c)
				neighborCounts[r][c] = count
				if count < 4 {
					queue = append(queue, Point{r, c})
				}
			}
		}
	}

	totalRemoved := 0
	head := 0
	for head < len(queue) {
		p := queue[head]
		head++

		if grid[p.r][p.c] == '.' {
			continue
		}

		grid[p.r][p.c] = '.'
		totalRemoved++

		// Notify neighbors
		for i := 0; i < 8; i++ {
			nr, nc := p.r+dr[i], p.c+dc[i]
			if nr >= 0 && nr < rows && nc >= 0 && nc < cols {
				if grid[nr][nc] == '@' {
					neighborCounts[nr][nc]--
					if neighborCounts[nr][nc] == 3 {
						queue = append(queue, Point{nr, nc})
					}
				}
			}
		}
	}

	return int64(totalRemoved)
}

func Run() {
	testPath := "../inputs/day04_test.txt"
	realPath := "../inputs/day04.txt"

	// Part 1 Test expect: 13
	// Part 2 Test expect: 43
	utils.RunSolution("Part 1", Part1, testPath, realPath, 13)
	utils.RunSolution("Part 2", Part2, testPath, realPath, 43)
}
