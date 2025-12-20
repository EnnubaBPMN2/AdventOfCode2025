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
	"fmt"
)

func main() {
	fmt.Println("🎄 Advent of Code 2025 - Go Solutions 🎄")
	fmt.Println("=========================================")
	fmt.Print("\nEnter day number (1-12): ")

	var day int
	_, err := fmt.Scanln(&day)
	if err != nil {
		fmt.Println("Invalid input")
		return
	}

	switch day {
	case 1:
		fmt.Println("\n📅 Day 1: Secret Entrance (Dial Rotation)")
		day01.Run()
	case 2:
		fmt.Println("\n📅 Day 2: Gift Shop")
		day02.Run()
	case 3:
		fmt.Println("\n📅 Day 3: Lobby")
		day03.Run()
	case 4:
		fmt.Println("\n📅 Day 4: Printing Department")
		day04.Run()
	case 5:
		fmt.Println("\n📅 Day 5: Cafeteria")
		day05.Run()
	case 6:
		fmt.Println("\n📅 Day 6: Trash Compactor")
		day06.Run()
	case 7:
		fmt.Println("\n📅 Day 7: Laboratories")
		day07.Run()
	case 8:
		fmt.Println("\n📅 Day 8: Playground")
		day08.Run()
	case 9:
		fmt.Println("\n📅 Day 9: Movie Theater")
		day09.Run()
	case 10:
		fmt.Println("\n📅 Day 10: Factory")
		day10.Run()
	case 11:
		fmt.Println("\n📅 Day 11: Reactor")
		day11.Run()
	case 12:
		fmt.Println("\n📅 Day 12: Christmas Tree Farm")
		day12.Run()
	default:
		fmt.Printf("Day %d not implemented yet\n", day)
	}

	fmt.Println("\n✨ Done!")
}
