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
            var digits = line.Trim().Select(c => int.Parse(c.ToString())).ToArray();
            int maxJoltage = -1;

            // Iterate through all pairs of indices (i, j) such that i < j
            for (int i = 0; i < digits.Length; i++)
            {
                for (int j = i + 1; j < digits.Length; j++)
                {
                    int joltage = digits[i] * 10 + digits[j];
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
            var digits = line.Trim().Select(c => int.Parse(c.ToString())).ToArray();
            var stack = new Stack<int>();
            int n = digits.Length;

            for (int i = 0; i < n; i++)
            {
                int digit = digits[i];
                int remaining = n - 1 - i;

                // While stack is not empty, current digit is greater than top of stack,
                // and we have enough remaining digits to fill the rest of the sequence
                while (stack.Count > 0 && digit > stack.Peek() && stack.Count + remaining >= k)
                {
                    stack.Pop();
                }

                if (stack.Count < k)
                {
                    stack.Push(digit);
                }
            }

            // Construct the number from the stack (stack is reversed order)
            var resultDigits = stack.Reverse().ToArray();
            string numberStr = string.Join("", resultDigits);
            
            if (long.TryParse(numberStr, out long maxJoltage))
            {
                totalOutputJoltage += maxJoltage;
            }
        }

        return totalOutputJoltage;
    }
}
