package day12

import (
	"adventofcode2025/aocgo/utils"
	"fmt"
	"strconv"
	"strings"
)

type Point struct {
	R, C int
}

type Shape struct {
	Points []Point
	Height int
	Width  int
	Area   int
}

type Region struct {
	Width  int
	Height int
	Counts []int
}

func parseShapes(input string) []Shape {
	sections := strings.Split(input, "\n\n")
	shapes := make([]Shape, 0)
	for _, section := range sections {
		lines := strings.Split(strings.TrimSpace(section), "\n")
		if len(lines) == 0 || !strings.Contains(lines[0], ":") {
			continue
		}
		// This is a shape section
		if strings.Contains(lines[0], "x") {
			continue // This is actually a region line, but we split by double newline
		}

		shapeLines := lines[1:]
		if len(shapeLines) == 0 {
			continue
		}

		points := make([]Point, 0)
		maxR, maxC := 0, 0
		for r, line := range shapeLines {
			for c, ch := range line {
				if ch == '#' {
					points = append(points, Point{r, c})
					if r > maxR {
						maxR = r
					}
					if c > maxC {
						maxC = c
					}
				}
			}
		}
		shapes = append(shapes, Shape{
			Points: points,
			Height: maxR + 1,
			Width:  maxC + 1,
			Area:   len(points),
		})
	}
	return shapes
}

func parseRegions(input string) ([]Shape, []Region) {
	lines := strings.Split(strings.ReplaceAll(input, "\r\n", "\n"), "\n")
	shapesRaw := make([][]string, 0)
	regions := make([]Region, 0)

	i := 0
	for i < len(lines) {
		line := strings.TrimSpace(lines[i])
		if line == "" {
			i++
			continue
		}

		if strings.Contains(line, "x") && strings.Contains(line, ":") {
			parts := strings.Split(line, ":")
			dimParts := strings.Split(strings.TrimSpace(parts[0]), "x")
			w, _ := strconv.Atoi(dimParts[0])
			h, _ := strconv.Atoi(dimParts[1])
			countParts := strings.Fields(strings.TrimSpace(parts[1]))
			counts := make([]int, len(countParts))
			for j, cp := range countParts {
				counts[j], _ = strconv.Atoi(cp)
			}
			regions = append(regions, Region{Width: w, Height: h, Counts: counts})
			i++
		} else if strings.Contains(line, ":") {
			i++
			shapeLines := make([]string, 0)
			for i < len(lines) && strings.TrimSpace(lines[i]) != "" && !strings.Contains(lines[i], ":") {
				shapeLines = append(shapeLines, lines[i])
				i++
			}
			shapesRaw = append(shapesRaw, shapeLines)
		} else {
			i++
		}
	}

	shapes := make([]Shape, len(shapesRaw))
	for i, raw := range shapesRaw {
		points := make([]Point, 0)
		maxR, maxC := 0, 0
		for r, line := range raw {
			for c, ch := range line {
				if ch == '#' {
					points = append(points, Point{r, c})
					if r > maxR {
						maxR = r
					}
					if c > maxC {
						maxC = c
					}
				}
			}
		}
		shapes[i] = Shape{
			Points: points,
			Height: maxR + 1,
			Width:  maxC + 1,
			Area:   len(points),
		}
	}

	return shapes, regions
}

func getOrientations(s Shape) []Shape {
	unique := make(map[string]Shape)

	current := s
	for r := 0; r < 4; r++ {
		normed := normalize(current)
		unique[toString(normed)] = normed

		flipped := flip(current)
		normedFlipped := normalize(flipped)
		unique[toString(normedFlipped)] = normedFlipped

		current = rotate(current)
	}

	res := make([]Shape, 0, len(unique))
	for _, shape := range unique {
		res = append(res, shape)
	}
	return res
}

func normalize(s Shape) Shape {
	minR, minC := 1000, 1000
	for _, p := range s.Points {
		if p.R < minR {
			minR = p.R
		}
		if p.C < minC {
			minC = p.C
		}
	}
	newPoints := make([]Point, len(s.Points))
	maxR, maxC := 0, 0
	for i, p := range s.Points {
		newPoints[i] = Point{p.R - minR, p.C - minC}
		if newPoints[i].R > maxR {
			maxR = newPoints[i].R
		}
		if newPoints[i].C > maxC {
			maxC = newPoints[i].C
		}
	}
	return Shape{Points: newPoints, Height: maxR + 1, Width: maxC + 1, Area: s.Area}
}

func rotate(s Shape) Shape {
	newPoints := make([]Point, len(s.Points))
	for i, p := range s.Points {
		newPoints[i] = Point{p.C, -p.R}
	}
	return Shape{Points: newPoints, Area: s.Area}
}

func flip(s Shape) Shape {
	newPoints := make([]Point, len(s.Points))
	for i, p := range s.Points {
		newPoints[i] = Point{p.R, -p.C}
	}
	return Shape{Points: newPoints, Area: s.Area}
}

func toString(s Shape) string {
	grid := make(map[Point]bool)
	for _, p := range s.Points {
		grid[p] = true
	}
	var sb strings.Builder
	for r := 0; r < s.Height; r++ {
		for c := 0; c < s.Width; c++ {
			if grid[Point{r, c}] {
				sb.WriteByte('#')
			} else {
				sb.WriteByte('.')
			}
		}
		sb.WriteByte('\n')
	}
	return sb.String()
}

func canPlace(grid []bool, w, h int, s Shape, r, c int) bool {
	if r+s.Height > h || c+s.Width > w {
		return false
	}
	for _, p := range s.Points {
		if grid[(r+p.R)*w+(c+p.C)] {
			return false
		}
	}
	return true
}

func place(grid []bool, w int, s Shape, r, c int, val bool) {
	for _, p := range s.Points {
		grid[(r+p.R)*w+(c+p.C)] = val
	}
}

func solve(grid []bool, w, h int, counts []int, orientations [][]Shape) bool {
	// Find first shape type that still has count > 0
	shapeIdx := -1
	for i, c := range counts {
		if c > 0 {
			shapeIdx = i
			break
		}
	}

	// All shapes placed
	if shapeIdx == -1 {
		return true
	}

	for _, orient := range orientations[shapeIdx] {
		for r := 0; r <= h-orient.Height; r++ {
			for c := 0; c <= w-orient.Width; c++ {
				if canPlace(grid, w, h, orient, r, c) {
					place(grid, w, orient, r, c, true)
					counts[shapeIdx]--
					if solve(grid, w, h, counts, orientations) {
						return true
					}
					counts[shapeIdx]++
					place(grid, w, orient, r, c, false)
				}
			}
		}
	}

	return false
}

func Part1(input string) int64 {
	shapes, regions := parseRegions(input)
	orientations := make([][]Shape, len(shapes))
	for i, s := range shapes {
		orientations[i] = getOrientations(s)
	}

	var count int64
	for _, reg := range regions {
		requiredArea := 0
		for i, c := range reg.Counts {
			requiredArea += c * shapes[i].Area
		}
		if requiredArea > reg.Width*reg.Height {
			continue
		}

		grid := make([]bool, reg.Width*reg.Height)
		counts := make([]int, len(reg.Counts))
		copy(counts, reg.Counts)

		if solve(grid, reg.Width, reg.Height, counts, orientations) {
			count++
		}
	}
	return count
}

func Run() {
	testPath := "../inputs/day12_test.txt"
	realPath := "../inputs/day12.txt"

	utils.RunSolution("Part 1", Part1, testPath, realPath, 2)
	fmt.Println("\n🎄 Part 2 automatically completed! Both stars earned! 🎄")
}
