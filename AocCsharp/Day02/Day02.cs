using AocCsharp.Utils;

namespace AocCsharp.Day02;

public static class Day02
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day02_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day02.txt");

        // Part 1
        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 1227775554);
        
        // Part 2
        TestRunner.RunSolution("Part 2", Part2, testInputPath, realInputPath, expectedTestResult: 4174379265);
    }

    public static long Part1(string input)
    {
        return RunPart(input, IsInvalidIdPart1);
    }

    public static long Part2(string input)
    {
        return RunPart(input, IsInvalidIdPart2);
    }

    private static long RunPart(string input, Func<long, bool> validator)
    {
        // Input format: "11-22,95-115,..."
        input = input.Replace("\r", "").Replace("\n", "").Trim();
        
        var ranges = input.Split(',', StringSplitOptions.RemoveEmptyEntries);
        long totalInvalidSum = 0;

        foreach (var range in ranges)
        {
            var parts = range.Split('-');
            if (parts.Length != 2) continue;

            if (long.TryParse(parts[0], out long min) && long.TryParse(parts[1], out long max))
            {
                for (long i = min; i <= max; i++)
                {
                    if (validator(i))
                    {
                        totalInvalidSum += i;
                    }
                }
            }
        }

        return totalInvalidSum;
    }

    private static bool IsInvalidIdPart1(long id)
    {
        string s = id.ToString();
        if (s.Length % 2 != 0) return false;

        int half = s.Length / 2;
        string firstHalf = s.Substring(0, half);
        string secondHalf = s.Substring(half);

        return firstHalf == secondHalf;
    }

    private static bool IsInvalidIdPart2(long id)
    {
        string s = id.ToString();
        int len = s.Length;

        // Try all possible pattern lengths L
        // The pattern must repeat at least twice, so L can go up to len / 2
        for (int L = 1; L <= len / 2; L++)
        {
            if (len % L == 0)
            {
                int k = len / L; // Number of repetitions
                // k is guaranteed to be >= 2 because L <= len / 2
                
                string pattern = s.Substring(0, L);
                
                // Check if s is composed of k repetitions of pattern
                bool match = true;
                for (int i = 1; i < k; i++)
                {
                    if (s.Substring(i * L, L) != pattern)
                    {
                        match = false;
                        break;
                    }
                }

                if (match) return true;
            }
        }

        return false;
    }
}
