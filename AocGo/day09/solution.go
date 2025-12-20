package day09

import (
	"adventofcode2025/aocgo/utils"
	"strconv"
	"strings"
)

type Point struct {
	X, Y int64
}

func parsePoints(input string) []Point {
	lines := strings.Split(strings.TrimSpace(input), "\n")
	points := make([]Point, 0, len(lines))
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		parts := strings.Split(line, ",")
		if len(parts) == 2 {
			x, _ := strconv.ParseInt(strings.TrimSpace(parts[0]), 10, 64)
			y, _ := strconv.ParseInt(strings.TrimSpace(parts[1]), 10, 64)
			points = append(points, Point{X: x, Y: y})
		}
	}
	return points
}

func abs(x int64) int64 {
	if x < 0 {
		return -x
	}
	return x
}

func min(a, b int64) int64 {
	if a < b {
		return a
	}
	return b
}

func max(a, b int64) int64 {
	if a > b {
		return a
	}
	return b
}

func isPointOnSegment(p, s1, s2 Point) bool {
	if s1.X == s2.X && s1.X == p.X {
		return p.Y >= min(s1.Y, s2.Y) && p.Y <= max(s1.Y, s2.Y)
	}
	if s1.Y == s2.Y && s1.Y == p.Y {
		return p.X >= min(s1.X, s2.X) && p.X <= max(s1.X, s2.X)
	}
	return false
}

func isInsidePolygon(p Point, polygon []Point) bool {
	intersections := 0
	n := len(polygon)
	for i := 0; i < n; i++ {
		p1 := polygon[i]
		p2 := polygon[(i+1)%n]

		if (p1.Y > p.Y) != (p2.Y > p.Y) {
			intersectX := float64(p2.X-p1.X)*float64(p.Y-p1.Y)/float64(p2.Y-p1.Y) + float64(p1.X)
			if float64(p.X) < intersectX {
				intersections++
			}
		}
	}
	return (intersections % 2) == 1
}

func isInsideOrOnBoundary(p Point, polygon []Point) bool {
	for i := 0; i < len(polygon); i++ {
		if isPointOnSegment(p, polygon[i], polygon[(i+1)%len(polygon)]) {
			return true
		}
	}
	return isInsidePolygon(p, polygon)
}

func direction(p1, p2, p3 Point) int {
	val := (p3.Y-p1.Y)*(p2.X-p1.X) - (p2.Y-p1.Y)*(p3.X-p1.X)
	if val == 0 {
		return 0
	}
	if val > 0 {
		return 1
	}
	return -1
}

func segmentsProperlyIntersect(p1, p2, p3, p4 Point) bool {
	d1 := direction(p3, p4, p1)
	d2 := direction(p3, p4, p2)
	d3 := direction(p1, p2, p3)
	d4 := direction(p1, p2, p4)

	return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) && ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))
}

func Part1(input string) int64 {
	points := parsePoints(input)
	if len(points) < 2 {
		return 0
	}

	maxArea := int64(0)
	for i := 0; i < len(points); i++ {
		for j := i + 1; j < len(points); j++ {
			p1, p2 := points[i], points[j]
			width := abs(p1.X-p2.X) + 1
			height := abs(p1.Y-p2.Y) + 1
			area := width * height
			if area > maxArea {
				maxArea = area
			}
		}
	}
	return maxArea
}

func Part2(input string) int64 {
	points := parsePoints(input)
	if len(points) < 2 {
		return 0
	}

	maxArea := int64(0)
	n := len(points)

	for i := 0; i < n; i++ {
		for j := i + 1; j < n; j++ {
			p1, p2 := points[i], points[j]
			minX, maxX := min(p1.X, p2.X), max(p1.X, p2.X)
			minY, maxY := min(p1.Y, p2.Y), max(p1.Y, p2.Y)

			// Corner checks
			if !isInsideOrOnBoundary(Point{minX, minY}, points) ||
				!isInsideOrOnBoundary(Point{minX, maxY}, points) ||
				!isInsideOrOnBoundary(Point{maxX, minY}, points) ||
				!isInsideOrOnBoundary(Point{maxX, maxY}, points) {
				continue
			}

			// Interior tile check
			hasInterior := false
			for k := 0; k < n; k++ {
				pk := points[k]
				if pk.X > minX && pk.X < maxX && pk.Y > minY && pk.Y < maxY {
					hasInterior = true
					break
				}
			}
			if hasInterior {
				continue
			}

			// Boundary crossing check
			hasCrossing := false
			rectCorners := []Point{
				{minX, minY}, {maxX, minY}, {maxX, maxY}, {minX, maxY},
			}
			for k := 0; k < n; k++ {
				pk1 := points[k]
				pk2 := points[(k+1)%n]

				for r := 0; r < 4; r++ {
					if segmentsProperlyIntersect(pk1, pk2, rectCorners[r], rectCorners[(r+1)%4]) {
						hasCrossing = true
						break
					}
				}
				if hasCrossing {
					break
				}
			}

			if !hasCrossing {
				area := (maxX - minX + 1) * (maxY - minY + 1)
				if area > maxArea {
					maxArea = area
				}
			}
		}
	}

	return maxArea
}

func Run() {
	testPath := "../inputs/day09_test.txt"
	realPath := "../inputs/day09.txt"

	utils.RunSolution("Part 1", Part1, testPath, realPath, 50)
	utils.RunSolution("Part 2", Part2, testPath, realPath, 24)
}
