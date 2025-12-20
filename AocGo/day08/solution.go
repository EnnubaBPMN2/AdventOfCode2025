package day08

import (
	"adventofcode2025/aocgo/utils"
	"sort"
	"strconv"
	"strings"
)

type Point struct {
	X, Y, Z int64
}

type Edge struct {
	DistSq int64
	I, J   int
}

type DSU struct {
	Parent     []int
	Size       []int
	Components int
}

func NewDSU(n int) *DSU {
	parent := make([]int, n)
	size := make([]int, n)
	for i := 0; i < n; i++ {
		parent[i] = i
		size[i] = 1
	}
	return &DSU{Parent: parent, Size: size, Components: n}
}

func (d *DSU) Find(i int) int {
	if d.Parent[i] == i {
		return i
	}
	d.Parent[i] = d.Find(d.Parent[i])
	return d.Parent[i]
}

func (d *DSU) Union(i, j int) bool {
	rootI := d.Find(i)
	rootJ := d.Find(j)
	if rootI != rootJ {
		if d.Size[rootI] < d.Size[rootJ] {
			rootI, rootJ = rootJ, rootI
		}
		d.Parent[rootJ] = rootI
		d.Size[rootI] += d.Size[rootJ]
		d.Components--
		return true
	}
	return false
}

func parsePoints(input string) []Point {
	lines := strings.Split(strings.ReplaceAll(input, "\r\n", "\n"), "\n")
	points := make([]Point, 0)
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		parts := strings.Split(line, ",")
		if len(parts) == 3 {
			x, _ := strconv.ParseInt(parts[0], 10, 64)
			y, _ := strconv.ParseInt(parts[1], 10, 64)
			z, _ := strconv.ParseInt(parts[2], 10, 64)
			points = append(points, Point{X: x, Y: y, Z: z})
		}
	}
	return points
}

func getSortedEdges(points []Point) []Edge {
	n := len(points)
	edges := make([]Edge, 0, n*(n-1)/2)
	for i := 0; i < n; i++ {
		for j := i + 1; j < n; j++ {
			dx := points[i].X - points[j].X
			dy := points[i].Y - points[j].Y
			dz := points[i].Z - points[j].Z
			distSq := dx*dx + dy*dy + dz*dz
			edges = append(edges, Edge{DistSq: distSq, I: i, J: j})
		}
	}
	sort.Slice(edges, func(i, j int) bool {
		if edges[i].DistSq == edges[j].DistSq {
			if edges[i].I == edges[j].I {
				return edges[i].J < edges[j].J
			}
			return edges[i].I < edges[j].I
		}
		return edges[i].DistSq < edges[j].DistSq
	})
	return edges
}

func Part1(input string) int64 {
	points := parsePoints(input)
	if len(points) == 0 {
		return 0
	}
	edges := getSortedEdges(points)
	dsu := NewDSU(len(points))

	limit := 1000
	if len(points) == 20 {
		limit = 10
	}

	for i := 0; i < limit && i < len(edges); i++ {
		dsu.Union(edges[i].I, edges[i].J)
	}

	circuitSizeMap := make(map[int]int64)
	for i := 0; i < len(points); i++ {
		root := dsu.Find(i)
		circuitSizeMap[root]++
	}

	sizes := make([]int64, 0, len(circuitSizeMap))
	for _, s := range circuitSizeMap {
		sizes = append(sizes, s)
	}
	sort.Slice(sizes, func(i, j int) bool { return sizes[i] > sizes[j] })

	res := int64(1)
	for i := 0; i < 3 && i < len(sizes); i++ {
		res *= sizes[i]
	}
	return res
}

func Part2(input string) int64 {
	points := parsePoints(input)
	if len(points) == 0 {
		return 0
	}
	edges := getSortedEdges(points)
	dsu := NewDSU(len(points))

	var lastI, lastJ int
	for _, edge := range edges {
		if dsu.Union(edge.I, edge.J) {
			lastI, lastJ = edge.I, edge.J
			if dsu.Components == 1 {
				break
			}
		}
	}

	return points[lastI].X * points[lastJ].X
}

func Run() {
	testPath := "../inputs/day08_test.txt"
	realPath := "../inputs/day08.txt"

	utils.RunSolution("Part 1", Part1, testPath, realPath, 40)
	utils.RunSolution("Part 2", Part2, testPath, realPath, 25272)
}
