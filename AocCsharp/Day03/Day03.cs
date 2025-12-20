using AocCsharp.Utils;

namespace AocCsharp.Day03;

public static class Day03
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day03_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day03.txt");

        // Part 1
        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 357);

        // Part 2
        TestRunner.RunSolution("Part 2", Part2, testInputPath, realInputPath, expectedTestResult: 3121910778619);
    }

    public static long Part1(string input)
    {
        // Input format: Multi-line string of digits
        input = input.Replace("\r", "").Trim();
        var lines = input.Split('\n', StringSplitOptions.RemoveEmptyEntries);

        long totalOutputJoltage = 0;

        foreach (var line in lines)
        {
            var trimmed = line.Trim();
            int maxJoltage = -1;

            // Iterate through all pairs of indices (i, j) such that i < j
            for (int i = 0; i < trimmed.Length; i++)
            {
                int digit_i = trimmed[i] - '0';
                for (int j = i + 1; j < trimmed.Length; j++)
                {
                    int digit_j = trimmed[j] - '0';
                    int joltage = digit_i * 10 + digit_j;
                    if (joltage > maxJoltage)
                    {
                        maxJoltage = joltage;
                    }
                }
            }

            if (maxJoltage != -1)
            {
                totalOutputJoltage += maxJoltage;
            }
        }

        return totalOutputJoltage;
    }

    public static long Part2(string input)
    {
        input = input.Replace("\r", "").Trim();
        var lines = input.Split('\n', StringSplitOptions.RemoveEmptyEntries);

        long totalOutputJoltage = 0;
        int k = 12; // Target length

        foreach (var line in lines)
        {
            var trimmed = line.Trim();
            var stack = new List<int>(k);
            int n = trimmed.Length;

            for (int i = 0; i < n; i++)
            {
                int digit = trimmed[i] - '0';
                int remaining = n - 1 - i;

                // While stack is not empty, current digit is greater than top of stack,
                // and we have enough remaining digits to fill the rest of the sequence
                while (stack.Count > 0 && digit > stack[stack.Count - 1] && stack.Count + remaining >= k)
                {
                    stack.RemoveAt(stack.Count - 1);
                }

                if (stack.Count < k)
                {
                    stack.Add(digit);
                }
            }

            // Construct the number directly from digits
            long maxJoltage = 0;
            for (int i = 0; i < stack.Count; i++)
            {
                maxJoltage = maxJoltage * 10 + stack[i];
            }

            totalOutputJoltage += maxJoltage;
        }

        return totalOutputJoltage;
    }
}
