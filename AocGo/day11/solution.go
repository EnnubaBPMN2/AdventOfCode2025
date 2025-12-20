package day11

import (
	"adventofcode2025/aocgo/utils"
	"strings"
)

type Graph struct {
	Adj      [][]int
	NodeToID map[string]int
	IDToNode []string
}

func parseGraph(input string) *Graph {
	lines := strings.Split(strings.ReplaceAll(input, "\r\n", "\n"), "\n")
	rawAdj := make(map[string][]string)
	nodes := make(map[string]bool)

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		parts := strings.Split(line, ":")
		if len(parts) != 2 {
			continue
		}
		u := strings.TrimSpace(parts[0])
		nodes[u] = true
		targets := strings.Fields(parts[1])
		for _, v := range targets {
			v = strings.TrimSpace(v)
			rawAdj[u] = append(rawAdj[u], v)
			nodes[v] = true
		}
	}

	idToNode := make([]string, 0, len(nodes))
	nodeToID := make(map[string]int)
	for n := range nodes {
		nodeToID[n] = len(idToNode)
		idToNode = append(idToNode, n)
	}

	adj := make([][]int, len(idToNode))
	for u, vList := range rawAdj {
		uID := nodeToID[u]
		for _, v := range vList {
			adj[uID] = append(adj[uID], nodeToID[v])
		}
	}

	return &Graph{Adj: adj, NodeToID: nodeToID, IDToNode: idToNode}
}

func Part1(input string) int64 {
	g := parseGraph(input)
	startID, okStart := g.NodeToID["you"]
	endID, okEnd := g.NodeToID["out"]
	if !okStart || !okEnd {
		return 0
	}

	memo := make([]int64, len(g.IDToNode))
	for i := range memo {
		memo[i] = -1
	}

	var dfs func(int) int64
	dfs = func(u int) int64 {
		if u == endID {
			return 1
		}
		if memo[u] != -1 {
			return memo[u]
		}

		var count int64
		for _, v := range g.Adj[u] {
			count += dfs(v)
		}
		memo[u] = count
		return count
	}

	return dfs(startID)
}

func Part2(input string) int64 {
	g := parseGraph(input)
	startID, okStart := g.NodeToID["svr"]
	endID, okEnd := g.NodeToID["out"]
	dacID, okDac := g.NodeToID["dac"]
	fftID, okFft := g.NodeToID["fft"]

	if !okStart || !okEnd {
		return 0
	}

	// State: (nodeID, mask) where mask bits: 0=dac, 1=fft
	memo := make([][4]int64, len(g.IDToNode))
	for i := range memo {
		for j := 0; j < 4; j++ {
			memo[i][j] = -1
		}
	}

	var dfs func(int, int) int64
	dfs = func(u int, mask int) int64 {
		newMask := mask
		if okDac && u == dacID {
			newMask |= 1
		}
		if okFft && u == fftID {
			newMask |= 2
		}

		if u == endID {
			if (okDac && okFft && newMask == 3) || (!okDac && !okFft) || (okDac && !okFft && newMask&1 == 1) || (!okDac && okFft && newMask&2 == 2) {
				return 1
			}
			return 0
		}

		if memo[u][mask] != -1 {
			return memo[u][mask]
		}

		var count int64
		for _, v := range g.Adj[u] {
			count += dfs(v, newMask)
		}
		memo[u][mask] = count
		return count
	}

	return dfs(startID, 0)
}

func Run() {
	testPath := "../inputs/day11_test.txt"
	testPath2 := "../inputs/day11_test_part2.txt"
	realPath := "../inputs/day11.txt"

	utils.RunSolution("Part 1", Part1, testPath, realPath, 5)
	utils.RunSolution("Part 2", Part2, testPath2, realPath, 2)
}
