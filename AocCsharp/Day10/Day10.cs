using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using AocCsharp.Utils;

namespace AocCsharp.Day10;

public static class Day10
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day10_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day10.txt");

        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 7);
        TestRunner.RunSolution("Part 2", Part2, testInputPath, realInputPath, expectedTestResult: 33);
    }

    public static int Part1(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        int totalPresses = 0;

        foreach (var line in lines)
        {
            var (target, buttons) = ParseMachine(line);
            int minPresses = SolveGaussianElimination(target, buttons);
            totalPresses += minPresses;
        }

        return totalPresses;
    }

    public static int Part2(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        int totalPresses = 0;

        foreach (var line in lines)
        {
            var (targets, buttons) = ParseMachinePart2(line);
            int minPresses = SolveIntegerLinearProgramming(targets, buttons);
            totalPresses += minPresses;
        }

        return totalPresses;
    }

    private static (bool[] Target, List<bool[]> Buttons) ParseMachine(string line)
    {
        // Extract indicator pattern [.##.]
        int indicatorStart = line.IndexOf('[');
        int indicatorEnd = line.IndexOf(']');
        var indicatorSpan = line.AsSpan(indicatorStart + 1, indicatorEnd - indicatorStart - 1);

        bool[] target = new bool[indicatorSpan.Length];
        for (int i = 0; i < indicatorSpan.Length; i++)
        {
            target[i] = indicatorSpan[i] == '#';
        }

        // Extract button patterns (0,1,2)
        var buttons = new List<bool[]>();
        int pos = indicatorEnd + 1;

        while (pos < line.Length)
        {
            int openParen = line.IndexOf('(', pos);
            if (openParen == -1) break;

            int closeParen = line.IndexOf(')', openParen);
            var buttonSpan = line.AsSpan(openParen + 1, closeParen - openParen - 1);

            bool[] button = new bool[target.Length];
            int start = 0;
            while (start < buttonSpan.Length)
            {
                int commaPos = buttonSpan.Slice(start).IndexOf(',');
                ReadOnlySpan<char> numSpan = commaPos == -1
                    ? buttonSpan.Slice(start)
                    : buttonSpan.Slice(start, commaPos);

                if (int.TryParse(numSpan, out int idx))
                {
                    button[idx] = true;
                }

                if (commaPos == -1) break;
                start += commaPos + 1;
            }
            buttons.Add(button);
            pos = closeParen + 1;
        }

        return (target, buttons);
    }

    private static int SolveGaussianElimination(bool[] target, List<bool[]> buttons)
    {
        int numLights = target.Length;
        int numButtons = buttons.Count;

        // Build augmented matrix [A | b] for the system Ax = b in GF(2)
        // Each row represents an indicator light
        // Each column represents a button
        bool[,] matrix = new bool[numLights, numButtons + 1];

        for (int light = 0; light < numLights; light++)
        {
            for (int button = 0; button < numButtons; button++)
            {
                matrix[light, button] = buttons[button][light];
            }
            matrix[light, numButtons] = target[light];
        }

        // Perform Gaussian elimination in GF(2)
        int[] pivot = new int[numLights];
        for (int i = 0; i < numLights; i++) pivot[i] = -1;

        int col = 0;
        for (int row = 0; row < numLights && col < numButtons; col++)
        {
            // Find pivot
            int pivotRow = -1;
            for (int r = row; r < numLights; r++)
            {
                if (matrix[r, col])
                {
                    pivotRow = r;
                    break;
                }
            }

            if (pivotRow == -1) continue;

            // Swap rows
            if (pivotRow != row)
            {
                for (int c = 0; c <= numButtons; c++)
                {
                    bool temp = matrix[row, c];
                    matrix[row, c] = matrix[pivotRow, c];
                    matrix[pivotRow, c] = temp;
                }
            }

            pivot[row] = col;

            // Eliminate column
            for (int r = 0; r < numLights; r++)
            {
                if (r != row && matrix[r, col])
                {
                    for (int c = 0; c <= numButtons; c++)
                    {
                        matrix[r, c] ^= matrix[row, c];
                    }
                }
            }

            row++;
        }

        // Check for inconsistency
        for (int r = 0; r < numLights; r++)
        {
            bool allZero = true;
            for (int c = 0; c < numButtons; c++)
            {
                if (matrix[r, c])
                {
                    allZero = false;
                    break;
                }
            }
            if (allZero && matrix[r, numButtons])
            {
                // No solution
                return int.MaxValue;
            }
        }

        // Find free variables (non-pivot columns)
        List<int> freeVars = new List<int>();
        for (int c = 0; c < numButtons; c++)
        {
            bool isPivot = false;
            for (int r = 0; r < numLights; r++)
            {
                if (pivot[r] == c)
                {
                    isPivot = true;
                    break;
                }
            }
            if (!isPivot) freeVars.Add(c);
        }

        int minPresses = int.MaxValue;

        // If there are too many free variables, limit the search
        // For small problems (like test), try all; for large, use heuristics
        int maxCombinations = Math.Min(1 << freeVars.Count, 1 << 15); // Limit to 32k combinations

        for (int mask = 0; mask < maxCombinations; mask++)
        {
            bool[] solution = new bool[numButtons];

            // Set free variables based on mask
            for (int i = 0; i < freeVars.Count && i < 15; i++)
            {
                solution[freeVars[i]] = ((mask >> i) & 1) == 1;
            }

            // Back-substitute for pivot variables
            for (int r = numLights - 1; r >= 0; r--)
            {
                if (pivot[r] == -1) continue;

                bool val = matrix[r, numButtons];
                for (int c = pivot[r] + 1; c < numButtons; c++)
                {
                    if (matrix[r, c] && solution[c])
                    {
                        val ^= true;
                    }
                }
                solution[pivot[r]] = val;
            }

            // Count presses
            int presses = 0;
            for (int i = 0; i < solution.Length; i++)
            {
                if (solution[i]) presses++;
            }
            minPresses = Math.Min(minPresses, presses);
        }

        return minPresses;
    }

    private static (int[] Targets, List<int[]> Buttons) ParseMachinePart2(string line)
    {
        // Extract joltage requirements {3,5,4,7}
        int joltsStart = line.IndexOf('{');
        int joltsEnd = line.IndexOf('}');
        var joltsSpan = line.AsSpan(joltsStart + 1, joltsEnd - joltsStart - 1);

        // Parse targets
        var targetsList = new List<int>();
        int start = 0;
        while (start < joltsSpan.Length)
        {
            int commaPos = joltsSpan.Slice(start).IndexOf(',');
            ReadOnlySpan<char> numSpan = commaPos == -1
                ? joltsSpan.Slice(start)
                : joltsSpan.Slice(start, commaPos);

            if (int.TryParse(numSpan, out int val))
            {
                targetsList.Add(val);
            }

            if (commaPos == -1) break;
            start += commaPos + 1;
        }
        int[] targets = targetsList.ToArray();

        // Extract button patterns (0,1,2) - they appear BEFORE the {targets}
        // Find the end of the indicator section first
        int indicatorEnd = line.IndexOf(']');

        var buttons = new List<int[]>();
        int pos = indicatorEnd + 1;

        // Parse all buttons between ] and {
        while (pos < joltsStart)
        {
            int openParen = line.IndexOf('(', pos);
            if (openParen == -1 || openParen >= joltsStart) break;

            int closeParen = line.IndexOf(')', openParen);
            var buttonSpan = line.AsSpan(openParen + 1, closeParen - openParen - 1);

            int[] button = new int[targets.Length];
            start = 0;
            while (start < buttonSpan.Length)
            {
                int commaPos = buttonSpan.Slice(start).IndexOf(',');
                ReadOnlySpan<char> numSpan = commaPos == -1
                    ? buttonSpan.Slice(start)
                    : buttonSpan.Slice(start, commaPos);

                if (int.TryParse(numSpan, out int idx))
                {
                    button[idx] = 1;
                }

                if (commaPos == -1) break;
                start += commaPos + 1;
            }
            buttons.Add(button);
            pos = closeParen + 1;
        }

        return (targets, buttons);
    }

    private static int SolveIntegerLinearProgramming(int[] targets, List<int[]> buttons)
    {
        int numCounters = targets.Length;
        int numButtons = buttons.Count;

        // Build matrix [A | b]
        double[,] matrix = new double[numCounters, numButtons + 1];

        for (int counter = 0; counter < numCounters; counter++)
        {
            for (int button = 0; button < numButtons; button++)
            {
                matrix[counter, button] = buttons[button][counter];
            }
            matrix[counter, numButtons] = targets[counter];
        }

        // Perform Gaussian elimination to get RREF
        int[] pivot = new int[numCounters];
        for (int i = 0; i < numCounters; i++) pivot[i] = -1;

        int col = 0;
        for (int row = 0; row < numCounters && col < numButtons; col++)
        {
            // Find pivot
            int pivotRow = -1;
            for (int r = row; r < numCounters; r++)
            {
                if (Math.Abs(matrix[r, col]) > 1e-9)
                {
                    pivotRow = r;
                    break;
                }
            }

            if (pivotRow == -1) continue;

            // Swap rows
            if (pivotRow != row)
            {
                for (int c = 0; c <= numButtons; c++)
                {
                    double temp = matrix[row, c];
                    matrix[row, c] = matrix[pivotRow, c];
                    matrix[pivotRow, c] = temp;
                }
            }

            pivot[row] = col;

            // Scale pivot row
            double pivotVal = matrix[row, col];
            for (int c = 0; c <= numButtons; c++)
            {
                matrix[row, c] /= pivotVal;
            }

            // Eliminate column
            for (int r = 0; r < numCounters; r++)
            {
                if (r != row && Math.Abs(matrix[r, col]) > 1e-9)
                {
                    double factor = matrix[r, col];
                    for (int c = 0; c <= numButtons; c++)
                    {
                        matrix[r, c] -= factor * matrix[row, c];
                    }
                }
            }

            row++;
        }

        // Find free variables
        List<int> freeVars = new List<int>();
        for (int c = 0; c < numButtons; c++)
        {
            bool isPivot = false;
            for (int r = 0; r < numCounters; r++)
            {
                if (pivot[r] == c)
                {
                    isPivot = true;
                    break;
                }
            }
            if (!isPivot) freeVars.Add(c);
        }

        int minPresses = int.MaxValue;

        // For systems with no free variables, there's a unique solution
        if (freeVars.Count == 0)
        {
            int[] solution = new int[numButtons];

            for (int r = 0; r < numCounters; r++)
            {
                if (pivot[r] == -1) continue;

                double val = matrix[r, numButtons];
                if (val < -1e-9 || Math.Abs(val - Math.Round(val)) > 1e-9)
                {
                    return 0;
                }

                solution[pivot[r]] = (int)Math.Round(val);
                if (solution[pivot[r]] < 0)
                {
                    return 0;
                }
            }

            int total = 0;
            for (int i = 0; i < solution.Length; i++)
            {
                total += solution[i];
            }
            return total;
        }

        // Use recursive search with pruning for free variables
        int[] currentSolution = new int[numButtons];
        int[] testSolution = new int[numButtons]; // Reuse instead of cloning
        int maxFreeValue = 0;
        for (int i = 0; i < targets.Length; i++)
        {
            if (targets[i] > maxFreeValue) maxFreeValue = targets[i];
        }

        void SearchSolutions(int freeVarIdx)
        {
            if (freeVarIdx == freeVars.Count)
            {
                // Back-substitute for pivot variables - reuse testSolution array
                Array.Copy(currentSolution, testSolution, numButtons);
                bool valid = true;

                for (int r = numCounters - 1; r >= 0; r--)
                {
                    if (pivot[r] == -1) continue;

                    double val = matrix[r, numButtons];
                    for (int c = pivot[r] + 1; c < numButtons; c++)
                    {
                        if (Math.Abs(matrix[r, c]) > 1e-9)
                        {
                            val -= matrix[r, c] * testSolution[c];
                        }
                    }

                    if (val < -1e-9 || Math.Abs(val - Math.Round(val)) > 1e-9)
                    {
                        valid = false;
                        break;
                    }

                    int roundedVal = (int)Math.Round(val);
                    if (roundedVal < 0)
                    {
                        valid = false;
                        break;
                    }

                    testSolution[pivot[r]] = roundedVal;
                }

                if (valid)
                {
                    int presses = 0;
                    for (int i = 0; i < testSolution.Length; i++)
                    {
                        presses += testSolution[i];
                    }
                    minPresses = Math.Min(minPresses, presses);
                }
                return;
            }

            // Try values for this free variable
            int varIdx = freeVars[freeVarIdx];
            int currentSum = 0;
            for (int i = 0; i < numButtons; i++)
            {
                currentSum += currentSolution[i];
            }
            int upperBound = Math.Min(maxFreeValue, minPresses - currentSum);

            for (int value = 0; value <= upperBound; value++)
            {
                currentSolution[varIdx] = value;
                SearchSolutions(freeVarIdx + 1);

                // Early exit if found perfect solution
                if (minPresses == 0) return;
            }
            currentSolution[varIdx] = 0;
        }

        SearchSolutions(0);
        return minPresses == int.MaxValue ? 0 : minPresses;
    }
}
