package day02

import (
	"adventofcode2025/aocgo/utils"
	"math"
	"sort"
	"strconv"
	"strings"
)

type Range struct {
	Min int64
	Max int64
}

func parseAndMergeRanges(input string) []Range {
	input = strings.TrimSpace(input)
	if input == "" {
		return nil
	}

	rawRanges := strings.Split(input, ",")
	ranges := make([]Range, 0, len(rawRanges))

	for _, rr := range rawRanges {
		rr = strings.TrimSpace(rr)
		if rr == "" {
			continue
		}
		parts := strings.Split(rr, "-")
		if len(parts) != 2 {
			continue
		}
		min, _ := strconv.ParseInt(parts[0], 10, 64)
		max, _ := strconv.ParseInt(parts[1], 10, 64)
		ranges = append(ranges, Range{Min: min, Max: max})
	}

	if len(ranges) == 0 {
		return nil
	}

	// Sort by Min
	sort.Slice(ranges, func(i, j int) bool {
		return ranges[i].Min < ranges[j].Min
	})

	// Merge
	merged := make([]Range, 0, len(ranges))
	curr := ranges[0]
	for i := 1; i < len(ranges); i++ {
		if ranges[i].Min <= curr.Max {
			if ranges[i].Max > curr.Max {
				curr.Max = ranges[i].Max
			}
		} else {
			merged = append(merged, curr)
			curr = ranges[i]
		}
	}
	merged = append(merged, curr)

	return merged
}

func isInRanges(val int64, ranges []Range) bool {
	// Binary search for efficiency if there are many ranges
	idx := sort.Search(len(ranges), func(i int) bool {
		return ranges[i].Max >= val
	})
	if idx < len(ranges) && val >= ranges[idx].Min {
		return true
	}
	return false
}

func Part1(input string) int64 {
	ranges := parseAndMergeRanges(input)
	var sum int64

	// Max 10 digits in input, so half-length max is 5
	for halfLen := 1; halfLen <= 5; halfLen++ {
		start := int64(math.Pow10(halfLen - 1))
		end := int64(math.Pow10(halfLen)) - 1

		for n := start; n <= end; n++ {
			s := strconv.FormatInt(n, 10)
			patternStr := s + s
			pattern, _ := strconv.ParseInt(patternStr, 10, 64)

			if isInRanges(pattern, ranges) {
				sum += pattern
			}
		}
	}

	return sum
}

func Part2(input string) int64 {
	ranges := parseAndMergeRanges(input)
	invalidIDs := make(map[int64]struct{})

	// Iterate over base pattern length
	for patternLen := 1; patternLen <= 5; patternLen++ {
		start := int64(math.Pow10(patternLen - 1))
		end := int64(math.Pow10(patternLen)) - 1

		for n := start; n <= end; n++ {
			s := strconv.FormatInt(n, 10)
			current := s
			// Repeat at least twice, up to max 10 digits
			for k := 2; k <= 10/patternLen; k++ {
				current += s
				pattern, _ := strconv.ParseInt(current, 10, 64)
				if isInRanges(pattern, ranges) {
					invalidIDs[pattern] = struct{}{}
				}
			}
		}
	}

	var sum int64
	for id := range invalidIDs {
		sum += id
	}

	return sum
}

func Run() {
	testPath := "../inputs/day02_test.txt"
	realPath := "../inputs/day02.txt"

	// C# test results for comparison:
	// Part 1 Test: 1227775554
	// Part 2 Test: 4174379265
	utils.RunSolution("Part 1", Part1, testPath, realPath, 1227775554)
	utils.RunSolution("Part 2", Part2, testPath, realPath, 4174379265)
}
