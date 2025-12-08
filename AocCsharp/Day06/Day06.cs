using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using AocCsharp.Utils;

namespace AocCsharp.Day06;

public static class Day06
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day06_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day06.txt");

        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 4277556);
        TestRunner.RunSolution("Part 2", Part2, testInputPath, realInputPath, expectedTestResult: 3263827);
    }

    public static long Part1(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0) return 0;

        int height = lines.Length;
        int width = lines.Max(l => l.Length);

        // Pad lines to ensure they are all the same length
        var grid = lines.Select(l => l.PadRight(width)).ToArray();

        var problems = new List<(List<long> Numbers, char Op)>();
        
        int? startCol = null;

        for (int col = 0; col < width; col++)
        {
            bool isEmptyCol = true;
            for (int row = 0; row < height; row++)
            {
                if (grid[row][col] != ' ')
                {
                    isEmptyCol = false;
                    break;
                }
            }

            if (!isEmptyCol)
            {
                if (startCol == null)
                {
                    startCol = col;
                }
            }
            else
            {
                if (startCol != null)
                {
                    // End of a block
                    problems.Add(ParseProblem(grid, startCol.Value, col - 1));
                    startCol = null;
                }
            }
        }

        // Handle last block if it extends to the edge
        if (startCol != null)
        {
            problems.Add(ParseProblem(grid, startCol.Value, width - 1));
        }

        long total = 0;
        foreach (var p in problems)
        {
            long result = p.Numbers[0];
            for (int i = 1; i < p.Numbers.Count; i++)
            {
                if (p.Op == '+') result += p.Numbers[i];
                else if (p.Op == '*') result *= p.Numbers[i];
            }
            total += result;
        }

        return total;
    }

    private static (List<long> Numbers, char Op) ParseProblem(string[] grid, int startCol, int endCol)
    {
        var numbers = new List<long>();
        char op = ' ';

        int height = grid.Length;
        int width = endCol - startCol + 1;

        // Numbers are in all rows except the last
        for (int row = 0; row < height - 1; row++)
        {
            var substring = grid[row].Substring(startCol, width).Trim();
            if (!string.IsNullOrWhiteSpace(substring) && long.TryParse(substring, out long num))
            {
                numbers.Add(num);
            }
        }

        // Operator is in the last row
        var opString = grid[height - 1].Substring(startCol, width).Trim();
        if (!string.IsNullOrWhiteSpace(opString))
        {
            op = opString[0];
        }

        return (numbers, op);
    }

    public static long Part2(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0) return 0;

        int height = lines.Length;
        int width = lines.Max(l => l.Length);

        // Pad lines to ensure they are all the same length
        var grid = lines.Select(l => l.PadRight(width)).ToArray();

        var problems = new List<(List<long> Numbers, char Op)>();

        int? startCol = null;

        for (int col = 0; col < width; col++)
        {
            bool isEmptyCol = true;
            for (int row = 0; row < height; row++)
            {
                if (grid[row][col] != ' ')
                {
                    isEmptyCol = false;
                    break;
                }
            }

            if (!isEmptyCol)
            {
                if (startCol == null)
                {
                    startCol = col;
                }
            }
            else
            {
                if (startCol != null)
                {
                    // End of a block - parse reading right-to-left
                    problems.Add(ParseProblemRightToLeft(grid, startCol.Value, col - 1));
                    startCol = null;
                }
            }
        }

        // Handle last block if it extends to the edge
        if (startCol != null)
        {
            problems.Add(ParseProblemRightToLeft(grid, startCol.Value, width - 1));
        }

        long total = 0;
        foreach (var p in problems)
        {
            long result = p.Numbers[0];
            for (int i = 1; i < p.Numbers.Count; i++)
            {
                if (p.Op == '+') result += p.Numbers[i];
                else if (p.Op == '*') result *= p.Numbers[i];
            }
            total += result;
        }

        return total;
    }

    private static (List<long> Numbers, char Op) ParseProblemRightToLeft(string[] grid, int startCol, int endCol)
    {
        var numbers = new List<long>();
        char op = ' ';

        int height = grid.Length;
        int width = endCol - startCol + 1;

        // Read each column from right to left
        for (int col = endCol; col >= startCol; col--)
        {
            var digitChars = new List<char>();

            // Read digits from top to bottom in this column (rows 0 to height-2, excluding operator row)
            for (int row = 0; row < height - 1; row++)
            {
                char c = grid[row][col];
                if (c != ' ')
                {
                    digitChars.Add(c);
                }
            }

            // Build number from these digits
            if (digitChars.Count > 0)
            {
                var numStr = new string(digitChars.ToArray());
                if (long.TryParse(numStr, out long num))
                {
                    numbers.Add(num);
                }
            }
        }

        // Operator is in the last row - find it anywhere in this block
        for (int col = startCol; col <= endCol; col++)
        {
            char c = grid[height - 1][col];
            if (c == '+' || c == '*')
            {
                op = c;
                break;
            }
        }

        return (numbers, op);
    }
}
