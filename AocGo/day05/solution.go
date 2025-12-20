package day05

import (
	"adventofcode2025/aocgo/utils"
	"sort"
	"strconv"
	"strings"
)

type Range struct {
	Start int64
	End   int64
}

// parseAndMergeRanges sorts and merges overlapping/adjacent ranges
func parseAndMergeRanges(input string) []Range {
	lines := strings.Split(strings.TrimSpace(input), "\n")
	ranges := make([]Range, 0, len(lines))

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		parts := strings.Split(line, "-")
		if len(parts) != 2 {
			continue
		}
		start, _ := strconv.ParseInt(parts[0], 10, 64)
		end, _ := strconv.ParseInt(parts[1], 10, 64)
		ranges = append(ranges, Range{Start: start, End: end})
	}

	if len(ranges) == 0 {
		return nil
	}

	// Sort by Start
	sort.Slice(ranges, func(i, j int) bool {
		return ranges[i].Start < ranges[j].Start
	})

	// Merge
	merged := make([]Range, 0, len(ranges))
	curr := ranges[0]
	for i := 1; i < len(ranges); i++ {
		// If next range starts before or exactly at current end + 1
		if ranges[i].Start <= curr.End+1 {
			if ranges[i].End > curr.End {
				curr.End = ranges[i].End
			}
		} else {
			merged = append(merged, curr)
			curr = ranges[i]
		}
	}
	merged = append(merged, curr)

	return merged
}

// isFresh checks if an ID is within any of the merged ranges using binary search
func isFresh(id int64, merged []Range) bool {
	n := len(merged)
	if n == 0 {
		return false
	}

	// Find the smallest index i such that merged[i].End >= id
	idx := sort.Search(n, func(i int) bool {
		return merged[i].End >= id
	})

	// Check if the found range actually contains the id
	if idx < n && id >= merged[idx].Start {
		return true
	}
	return false
}

func Part1(input string) int64 {
	sections := strings.Split(strings.ReplaceAll(input, "\r\n", "\n"), "\n\n")
	if len(sections) < 2 {
		return 0
	}

	mergedRanges := parseAndMergeRanges(sections[0])

	freshCount := int64(0)
	idsLines := strings.Split(sections[1], "\n")
	for _, line := range idsLines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		id, _ := strconv.ParseInt(line, 10, 64)
		if isFresh(id, mergedRanges) {
			freshCount++
		}
	}

	return freshCount
}

func Part2(input string) int64 {
	sections := strings.Split(strings.ReplaceAll(input, "\r\n", "\n"), "\n\n")
	if len(sections) == 0 {
		return 0
	}

	mergedRanges := parseAndMergeRanges(sections[0])

	totalFresh := int64(0)
	for _, r := range mergedRanges {
		totalFresh += (r.End - r.Start + 1)
	}

	return totalFresh
}

func Run() {
	testPath := "../inputs/day05_test.txt"
	realPath := "../inputs/day05.txt"

	// Part 1 Test: 3
	// Part 2 Test: 14
	utils.RunSolution("Part 1", Part1, testPath, realPath, 3)
	utils.RunSolution("Part 2", Part2, testPath, realPath, 14)
}
