package day10

import (
	"adventofcode2025/aocgo/utils"
	"math"
	"regexp"
	"strconv"
	"strings"
)

type Machine struct {
	Indicator []bool
	Buttons   [][]bool
	Jolts     []int64
}

func parseMachine(line string) Machine {
	// Simple regex to extract components
	indicatorRe := regexp.MustCompile(`\[([.#]+)\]`)
	buttonRe := regexp.MustCompile(`\(([\d,]+)\)`)
	joltsRe := regexp.MustCompile(`\{([\d,]+)\}`)

	indicatorMatch := indicatorRe.FindStringSubmatch(line)
	var indicator []bool
	if len(indicatorMatch) > 1 {
		indicator = make([]bool, len(indicatorMatch[1]))
		for i, c := range indicatorMatch[1] {
			indicator[i] = (c == '#')
		}
	}

	buttonMatches := buttonRe.FindAllStringSubmatch(line, -1)
	buttons := make([][]bool, len(buttonMatches))
	for i, m := range buttonMatches {
		indices := strings.Split(m[1], ",")
		button := make([]bool, len(indicator))
		for _, idxStr := range indices {
			idx, _ := strconv.Atoi(idxStr)
			if idx < len(button) {
				button[idx] = true
			}
		}
		buttons[i] = button
	}

	joltsMatch := joltsRe.FindStringSubmatch(line)
	var jolts []int64
	if len(joltsMatch) > 1 {
		joltStrs := strings.Split(joltsMatch[1], ",")
		jolts = make([]int64, len(joltStrs))
		for i, s := range joltStrs {
			v, _ := strconv.ParseInt(s, 10, 64)
			jolts[i] = v
		}
	}

	return Machine{Indicator: indicator, Buttons: buttons, Jolts: jolts}
}

func solveGF2(target []bool, buttons [][]bool) int64 {
	rows := len(target)
	cols := len(buttons)
	matrix := make([][]bool, rows)
	for i := 0; i < rows; i++ {
		matrix[i] = make([]bool, cols+1)
		for j := 0; j < cols; j++ {
			matrix[i][j] = buttons[j][i]
		}
		matrix[i][cols] = target[i]
	}

	pivot := make([]int, rows)
	for i := range pivot {
		pivot[i] = -1
	}

	r, c := 0, 0
	for r < rows && c < cols {
		pivotRow := -1
		for i := r; i < rows; i++ {
			if matrix[i][c] {
				pivotRow = i
				break
			}
		}

		if pivotRow == -1 {
			c++
			continue
		}

		matrix[r], matrix[pivotRow] = matrix[pivotRow], matrix[r]
		pivot[r] = c

		for i := 0; i < rows; i++ {
			if i != r && matrix[i][c] {
				for j := c; j <= cols; j++ {
					matrix[i][j] = matrix[i][j] != matrix[r][j]
				}
			}
		}
		r++
		c++
	}

	for i := 0; i < rows; i++ {
		allZero := true
		for j := 0; j < cols; j++ {
			if matrix[i][j] {
				allZero = false
				break
			}
		}
		if allZero && matrix[i][cols] {
			return math.MaxInt64 // Inconsistent
		}
	}

	isPivot := make([]bool, cols)
	for _, p := range pivot {
		if p != -1 {
			isPivot[p] = true
		}
	}

	freeVars := make([]int, 0)
	for j := 0; j < cols; j++ {
		if !isPivot[j] {
			freeVars = append(freeVars, j)
		}
	}

	var minPresses int64 = math.MaxInt64
	// Limit free variables to 15 to avoid explosion, though problem likely doesn't have many
	numFree := len(freeVars)
	if numFree > 15 {
		numFree = 15
	}
	limit := 1 << numFree

	for mask := 0; mask < limit; mask++ {
		sol := make([]bool, cols)
		for i := 0; i < numFree; i++ {
			if (mask >> i & 1) == 1 {
				sol[freeVars[i]] = true
			}
		}

		for i := rows - 1; i >= 0; i-- {
			pCol := pivot[i]
			if pCol == -1 {
				continue
			}
			val := matrix[i][cols]
			for j := pCol + 1; j < cols; j++ {
				if matrix[i][j] && sol[j] {
					val = val != true
				}
			}
			sol[pCol] = val
		}

		var count int64
		for _, v := range sol {
			if v {
				count++
			}
		}
		if count < minPresses {
			minPresses = count
		}
	}

	return minPresses
}

func solveILP(target []int64, buttons [][]bool) int64 {
	rows := len(target)
	cols := len(buttons)
	matrix := make([][]float64, rows)
	for i := 0; i < rows; i++ {
		matrix[i] = make([]float64, cols+1)
		for j := 0; j < cols; j++ {
			if buttons[j][i] {
				matrix[i][j] = 1.0
			}
		}
		matrix[i][cols] = float64(target[i])
	}

	pivot := make([]int, rows)
	for i := range pivot {
		pivot[i] = -1
	}

	const eps = 1e-9
	r, c := 0, 0
	for r < rows && c < cols {
		pivotRow := -1
		for i := r; i < rows; i++ {
			if math.Abs(matrix[i][c]) > eps {
				pivotRow = i
				break
			}
		}

		if pivotRow == -1 {
			c++
			continue
		}

		matrix[r], matrix[pivotRow] = matrix[pivotRow], matrix[r]
		pivot[r] = c

		divisor := matrix[r][c]
		for j := c; j <= cols; j++ {
			matrix[r][j] /= divisor
		}

		for i := 0; i < rows; i++ {
			if i != r && math.Abs(matrix[i][c]) > eps {
				factor := matrix[i][c]
				for j := c; j <= cols; j++ {
					matrix[i][j] -= factor * matrix[r][j]
				}
			}
		}
		r++
		c++
	}

	isPivot := make([]bool, cols)
	for _, p := range pivot {
		if p != -1 {
			isPivot[p] = true
		}
	}

	freeVars := make([]int, 0)
	for j := 0; j < cols; j++ {
		if !isPivot[j] {
			freeVars = append(freeVars, j)
		}
	}

	var maxTarget float64
	for _, t := range target {
		if float64(t) > maxTarget {
			maxTarget = float64(t)
		}
	}

	minPresses := int64(math.MaxInt64)

	var search func(idx int, currentSol []int64, currentSum int64)
	search = func(idx int, currentSol []int64, currentSum int64) {
		if idx == len(freeVars) {
			testSol := make([]int64, cols)
			copy(testSol, currentSol)
			valid := true
			var sum int64 = currentSum

			for i := rows - 1; i >= 0; i-- {
				pCol := pivot[i]
				if pCol == -1 {
					continue
				}

				val := matrix[i][cols]
				for j := pCol + 1; j < cols; j++ {
					if math.Abs(matrix[i][j]) > eps {
						val -= matrix[i][j] * float64(testSol[j])
					}
				}

				if val < -eps || math.Abs(val-math.Round(val)) > eps {
					valid = false
					break
				}
				v := int64(math.Round(val))
				if v < 0 {
					valid = false
					break
				}
				testSol[pCol] = v
				sum += v
			}

			if valid && sum < minPresses {
				minPresses = sum
			}
			return
		}

		vIdx := freeVars[idx]
		for val := int64(0); val <= int64(maxTarget); val++ {
			if currentSum+val >= minPresses {
				break
			}
			currentSol[vIdx] = val
			search(idx+1, currentSol, currentSum+val)
		}
		currentSol[vIdx] = 0
	}

	if len(freeVars) == 0 {
		testSol := make([]int64, cols)
		var sum int64
		valid := true
		for i := 0; i < rows; i++ {
			pCol := pivot[i]
			if pCol == -1 {
				// Check for inconsistency
				if math.Abs(matrix[i][cols]) > eps {
					valid = false
					break
				}
				continue
			}
			val := matrix[i][cols]
			if val < -eps || math.Abs(val-math.Round(val)) > eps {
				valid = false
				break
			}
			v := int64(math.Round(val))
			if v < 0 {
				valid = false
				break
			}
			testSol[pCol] = v
			sum += v
		}
		if valid {
			return sum
		}
		return 0
	}

	currentSol := make([]int64, cols)
	search(0, currentSol, 0)

	if minPresses == math.MaxInt64 {
		return 0
	}
	return minPresses
}

func Part1(input string) int64 {
	lines := strings.Split(strings.ReplaceAll(input, "\r\n", "\n"), "\n")
	var total int64
	for _, line := range lines {
		if strings.TrimSpace(line) == "" {
			continue
		}
		m := parseMachine(line)
		res := solveGF2(m.Indicator, m.Buttons)
		if res != math.MaxInt64 {
			total += res
		}
	}
	return total
}

func Part2(input string) int64 {
	lines := strings.Split(strings.ReplaceAll(input, "\r\n", "\n"), "\n")
	var total int64
	for _, line := range lines {
		if strings.TrimSpace(line) == "" {
			continue
		}
		m := parseMachine(line)
		res := solveILP(m.Jolts, m.Buttons)
		total += res
	}
	return total
}

func Run() {
	testPath := "../inputs/day10_test.txt"
	realPath := "../inputs/day10.txt"

	utils.RunSolution("Part 1", Part1, testPath, realPath, 7)
	utils.RunSolution("Part 2", Part2, testPath, realPath, 33)
}
