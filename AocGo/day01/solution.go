package day01

import (
	"adventofcode2025/aocgo/utils"
	"strconv"
	"strings"
)

// Part1 counts how many times the dial points at 0 after each rotation
func Part1(input string) int64 {
	rotations := strings.Fields(input)

	position := 50 // Starting position
	zeroCount := 0

	for _, rotation := range rotations {
		if len(rotation) < 2 {
			continue
		}

		direction := rotation[0]
		distance, _ := strconv.Atoi(rotation[1:])

		switch direction {
		case 'L':
			position = (position - distance) % 100
			if position < 0 {
				position += 100
			}
		case 'R':
			position = (position + distance) % 100
		}

		if position == 0 {
			zeroCount++
		}
	}

	return int64(zeroCount)
}

// Part2 counts how many times the dial points at 0 during rotations (including intermediate positions)
func Part2(input string) int64 {
	rotations := strings.Fields(input)

	position := 50 // Starting position
	zeroCount := 0

	for _, rotation := range rotations {
		if len(rotation) < 2 {
			continue
		}

		direction := rotation[0]
		distance, _ := strconv.Atoi(rotation[1:])

		switch direction {
		case 'R':
			// Moving right: count multiples of 100 in range (position, position + distance]
			zeroCount += (position + distance) / 100
			position = (position + distance) % 100

		case 'L':
			// Moving left: count multiples of 100 in range [position - distance, position)
			// Count = floor((pos - 1) / 100) - floor((pos - dist - 1) / 100)

			var startFloor int
			if (position - 1) < 0 {
				startFloor = -1
			} else {
				startFloor = 0
			}

			// Go's division truncates toward zero, so we need floor division
			temp := position - distance - 1
			var endFloor int
			if temp >= 0 {
				endFloor = temp / 100
			} else {
				// For negative numbers, adjust to get floor division
				endFloor = (temp - 99) / 100
			}

			zeroCount += startFloor - endFloor

			position = (position - distance) % 100
			if position < 0 {
				position += 100
			}
		}
	}

	return int64(zeroCount)
}

// Run executes both parts of Day 01
func Run() {
	testPath := "../inputs/day01_test.txt"
	realPath := "../inputs/day01.txt"

	utils.RunSolution("Part 1", Part1, testPath, realPath, 3)
	utils.RunSolution("Part 2", Part2, testPath, realPath, 6)
}
