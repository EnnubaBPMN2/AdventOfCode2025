package main

import (
	"adventofcode2025/aocgo/day01"
	"adventofcode2025/aocgo/day02"
	"adventofcode2025/aocgo/day03"
	"adventofcode2025/aocgo/day04"
	"adventofcode2025/aocgo/day05"
	"adventofcode2025/aocgo/day06"
	"adventofcode2025/aocgo/day07"
	"adventofcode2025/aocgo/day08"
	"adventofcode2025/aocgo/day09"
	"adventofcode2025/aocgo/day10"
	"adventofcode2025/aocgo/day11"
	"adventofcode2025/aocgo/day12"
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	fmt.Println("==================================================")
	fmt.Println("🎄 Advent of Code 2025 - Go Solutions 🎄")
	fmt.Println("==================================================")

	reader := bufio.NewReader(os.Stdin)

	for {
		fmt.Print("\nSelect a day (1-25) or 0 to exit: ")

		input, err := reader.ReadString('\n')
		if err != nil {
			fmt.Println("Invalid input. Please enter a number.")
			continue
		}

		input = strings.TrimSpace(input)
		day, err := strconv.Atoi(input)
		if err != nil {
			fmt.Println("Invalid input. Please enter a number.")
			continue
		}

		if day == 0 {
			fmt.Println("\n🎄 Happy Coding! 🎄")
			break
		}

		switch day {
		case 1:
			day01.Run()
		case 2:
			day02.Run()
		case 3:
			day03.Run()
		case 4:
			day04.Run()
		case 5:
			day05.Run()
		case 6:
			day06.Run()
		case 7:
			day07.Run()
		case 8:
			day08.Run()
		case 9:
			day09.Run()
		case 10:
			day10.Run()
		case 11:
			day11.Run()
		case 12:
			day12.Run()
		default:
			fmt.Printf("Day %d not implemented yet\n", day)
		}
	}
}
