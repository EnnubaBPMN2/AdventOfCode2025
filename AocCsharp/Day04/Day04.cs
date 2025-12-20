using System;
using System.IO;
using System.Linq;
using AocCsharp.Utils;

namespace AocCsharp.Day04;

public static class Day04
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day04_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day04.txt");

        // Part 1
        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 13);

        // Part 2
        TestRunner.RunSolution("Part 2", Part2, testInputPath, realInputPath, expectedTestResult: 43);
    }

    public static long Part1(string input)
    {
        input = input.Replace("\r", "").Trim();
        var lines = input.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        
        if (lines.Length == 0) return 0;

        int rows = lines.Length;
        int cols = lines[0].Length;
        int accessibleCount = 0;

        // Directions: N, NE, E, SE, S, SW, W, NW
        int[] dr = { -1, -1, 0, 1, 1, 1, 0, -1 };
        int[] dc = { 0, 1, 1, 1, 0, -1, -1, -1 };

        for (int r = 0; r < rows; r++)
        {
            for (int c = 0; c < cols; c++)
            {
                if (lines[r][c] == '@')
                {
                    int neighborCount = 0;
                    for (int i = 0; i < 8; i++)
                    {
                        int nr = r + dr[i];
                        int nc = c + dc[i];

                        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && lines[nr][nc] == '@')
                        {
                            neighborCount++;
                        }
                    }

                    if (neighborCount < 4)
                    {
                        accessibleCount++;
                    }
                }
            }
        }

        return accessibleCount;
    }

    public static long Part2(string input)
    {
        input = input.Replace("\r", "").Trim();
        var lines = input.Split('\n', StringSplitOptions.RemoveEmptyEntries);

        if (lines.Length == 0) return 0;

        int rows = lines.Length;
        int cols = lines[0].Length;

        // Convert to mutable grid using char arrays for better performance
        char[][] grid = new char[rows][];
        for (int r = 0; r < rows; r++)
        {
            grid[r] = lines[r].ToCharArray();
        }

        // Directions: N, NE, E, SE, S, SW, W, NW
        int[] dr = { -1, -1, 0, 1, 1, 1, 0, -1 };
        int[] dc = { 0, 1, 1, 1, 0, -1, -1, -1 };

        long totalRemoved = 0;

        while (true)
        {
            var toRemove = new System.Collections.Generic.List<(int r, int c)>();

            for (int r = 0; r < rows; r++)
            {
                for (int c = 0; c < cols; c++)
                {
                    if (grid[r][c] == '@')
                    {
                        int neighborCount = 0;
                        for (int i = 0; i < 8; i++)
                        {
                            int nr = r + dr[i];
                            int nc = c + dc[i];

                            if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && grid[nr][nc] == '@')
                            {
                                neighborCount++;
                            }
                        }

                        if (neighborCount < 4)
                        {
                            toRemove.Add((r, c));
                        }
                    }
                }
            }

            if (toRemove.Count == 0)
            {
                break;
            }

            totalRemoved += toRemove.Count;
            for (int i = 0; i < toRemove.Count; i++)
            {
                grid[toRemove[i].r][toRemove[i].c] = '.'; // Remove the roll
            }
        }

        return totalRemoved;
    }
}
