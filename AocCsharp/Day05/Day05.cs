using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using AocCsharp.Utils;

namespace AocCsharp.Day05;

public static class Day05
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day05_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day05.txt");

        // Part 1
        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 3);
        
        // Part 2
        TestRunner.RunSolution("Part 2", Part2, testInputPath, realInputPath, expectedTestResult: 14);
    }

    public static long Part1(string input)
    {
        input = input.Replace("\r", "").Trim();
        var sections = input.Split("\n\n", StringSplitOptions.RemoveEmptyEntries);

        if (sections.Length < 2) return 0;

        var rangeLines = sections[0].Split('\n', StringSplitOptions.RemoveEmptyEntries);
        var idLines = sections[1].Split('\n', StringSplitOptions.RemoveEmptyEntries);

        var ranges = ParseRanges(rangeLines);
        var ids = new List<long>();
        foreach (var line in idLines)
        {
            if (long.TryParse(line, out long id))
            {
                ids.Add(id);
            }
        }

        long freshCount = 0;
        foreach (var id in ids)
        {
            bool isFresh = false;
            foreach (var range in ranges)
            {
                if (id >= range.Start && id <= range.End)
                {
                    isFresh = true;
                    break;
                }
            }

            if (isFresh)
            {
                freshCount++;
            }
        }

        return freshCount;
    }

    public static long Part2(string input)
    {
        input = input.Replace("\r", "").Trim();
        var sections = input.Split("\n\n", StringSplitOptions.RemoveEmptyEntries);

        if (sections.Length < 1) return 0;

        var rangeLines = sections[0].Split('\n', StringSplitOptions.RemoveEmptyEntries);
        var ranges = ParseRanges(rangeLines);

        // Sort ranges by start
        ranges.Sort((a, b) => a.Start.CompareTo(b.Start));

        var mergedRanges = new List<(long Start, long End)>();
        if (ranges.Count > 0)
        {
            var currentRange = ranges[0];
            for (int i = 1; i < ranges.Count; i++)
            {
                var nextRange = ranges[i];
                // Check for overlap or adjacency (e.g., 3-5 and 6-8 should merge to 3-8? No, problem says "fresh if in any range", so 3-5 and 6-8 are contiguous integers. 5 and 6 are adjacent.
                // Actually, the problem says "3-5 means 3, 4, 5". "16-20 means 16..20".
                // If we have 3-5 and 5-7, they overlap at 5. Union is 3-7.
                // If we have 3-5 and 6-8, they don't overlap. Union is 3-5 and 6-8. Total count is (5-3+1) + (8-6+1) = 3 + 3 = 6.
                // Wait, if 3-5 and 6-8 are merged into 3-8, count is 8-3+1 = 6. Correct.
                // So if nextRange.Start <= currentRange.End + 1, we can merge?
                // The problem asks for "how many ingredient IDs are considered to be fresh".
                // If ranges are 1-2 and 4-5. Fresh: 1, 2, 4, 5. Count 4.
                // If merged to 1-5 (incorrect), count is 5.
                // So we only merge if they actually overlap or touch?
                // "The ranges can also overlap".
                // If 1-5 and 6-10. Fresh: 1,2,3,4,5 and 6,7,8,9,10. Total 10.
                // If merged to 1-10. Total 10.
                // So yes, if nextRange.Start <= currentRange.End + 1, we can merge them into a single contiguous block of integers.
                
                if (nextRange.Start <= currentRange.End + 1)
                {
                    currentRange.End = Math.Max(currentRange.End, nextRange.End);
                }
                else
                {
                    mergedRanges.Add(currentRange);
                    currentRange = nextRange;
                }
            }
            mergedRanges.Add(currentRange);
        }

        long totalFresh = 0;
        foreach (var range in mergedRanges)
        {
            totalFresh += (range.End - range.Start + 1);
        }

        return totalFresh;
    }

    private static List<(long Start, long End)> ParseRanges(string[] lines)
    {
        var ranges = new List<(long Start, long End)>(lines.Length);
        foreach (var line in lines)
        {
            int dashIndex = line.IndexOf('-');
            if (dashIndex > 0 && dashIndex < line.Length - 1)
            {
                if (long.TryParse(line.AsSpan(0, dashIndex), out long start) &&
                    long.TryParse(line.AsSpan(dashIndex + 1), out long end))
                {
                    ranges.Add((start, end));
                }
            }
        }
        return ranges;
    }
}
