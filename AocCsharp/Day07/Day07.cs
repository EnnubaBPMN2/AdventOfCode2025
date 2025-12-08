using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using AocCsharp.Utils;

namespace AocCsharp.Day07;

public static class Day07
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day07_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day07.txt");

        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 21);
        TestRunner.RunSolution("Part 2", Part2, testInputPath, realInputPath, expectedTestResult: 40);
    }

    public static long Part1(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0) return 0;

        var grid = lines.Select(l => l.ToCharArray()).ToArray();
        int height = grid.Length;
        int width = grid[0].Length;

        // Find starting position 'S'
        int startRow = -1, startCol = -1;
        for (int row = 0; row < height; row++)
        {
            for (int col = 0; col < width; col++)
            {
                if (grid[row][col] == 'S')
                {
                    startRow = row;
                    startCol = col;
                    break;
                }
            }
            if (startRow != -1) break;
        }

        // Simulate beams moving downward
        // Each beam is represented by its column position at each row
        // We'll track active beams as they move down row by row
        var currentBeams = new HashSet<int> { startCol };
        int splitCount = 0;

        for (int row = startRow + 1; row < height; row++)
        {
            var nextBeams = new HashSet<int>();

            foreach (int col in currentBeams)
            {
                char cell = grid[row][col];

                if (cell == '^')
                {
                    // Splitter encountered - beam stops, creates two new beams
                    splitCount++;

                    // Add beams to the left and right
                    if (col - 1 >= 0)
                    {
                        nextBeams.Add(col - 1);
                    }
                    if (col + 1 < width)
                    {
                        nextBeams.Add(col + 1);
                    }
                }
                else
                {
                    // Empty space - beam continues downward
                    nextBeams.Add(col);
                }
            }

            currentBeams = nextBeams;

            // If no beams left, we're done
            if (currentBeams.Count == 0)
            {
                break;
            }
        }

        return splitCount;
    }

    public static long Part2(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0) return 0;

        var grid = lines.Select(l => l.ToCharArray()).ToArray();
        int height = grid.Length;
        int width = grid[0].Length;

        // Find starting position 'S'
        int startRow = -1, startCol = -1;
        for (int row = 0; row < height; row++)
        {
            for (int col = 0; col < width; col++)
            {
                if (grid[row][col] == 'S')
                {
                    startRow = row;
                    startCol = col;
                    break;
                }
            }
            if (startRow != -1) break;
        }

        // For Part 2, we track the number of distinct timelines/paths
        // Each timeline is counted by tracking how many paths lead to each position
        var currentPaths = new Dictionary<int, long> { { startCol, 1 } };

        for (int row = startRow + 1; row < height; row++)
        {
            var nextPaths = new Dictionary<int, long>();

            foreach (var kvp in currentPaths)
            {
                int col = kvp.Key;
                long pathCount = kvp.Value;
                char cell = grid[row][col];

                if (cell == '^')
                {
                    // Splitter - particle takes both paths (quantum splitting)
                    // Each existing path splits into two timelines
                    if (col - 1 >= 0)
                    {
                        if (!nextPaths.ContainsKey(col - 1))
                            nextPaths[col - 1] = 0;
                        nextPaths[col - 1] += pathCount;
                    }
                    if (col + 1 < width)
                    {
                        if (!nextPaths.ContainsKey(col + 1))
                            nextPaths[col + 1] = 0;
                        nextPaths[col + 1] += pathCount;
                    }
                }
                else
                {
                    // Empty space - particle continues downward
                    if (!nextPaths.ContainsKey(col))
                        nextPaths[col] = 0;
                    nextPaths[col] += pathCount;
                }
            }

            currentPaths = nextPaths;

            // If no paths left, we're done
            if (currentPaths.Count == 0)
            {
                break;
            }
        }

        // Sum all timelines that reach the bottom
        return currentPaths.Values.Sum();
    }
}
