namespace AocCsharp.Utils;

public static class TestRunner
{
    /// <summary>
    /// Runs a test case and compares the result with expected value
    /// </summary>
    public static bool RunTest<T>(string testName, Func<T> testFunc, T expected)
    {
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.Write($"Running {testName}... ");
        Console.ResetColor();

        try
        {
            var result = testFunc();
            var passed = EqualityComparer<T>.Default.Equals(result, expected);

            if (passed)
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"✓ PASSED (Result: {result})");
            }
            else
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"✗ FAILED (Expected: {expected}, Got: {result})");
            }
            Console.ResetColor();

            return passed;
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine($"✗ ERROR: {ex.Message}");
            Console.ResetColor();
            return false;
        }
    }

    /// <summary>
    /// Runs a solution part with both test and real inputs
    /// </summary>
    public static void RunSolution<T>(string partName, Func<string, T> solver, string testInputPath, string realInputPath, T? expectedTestResult = default)
    {
        Console.WriteLine();
        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.WriteLine($"=== {partName} ===");
        Console.ResetColor();

        // Run test if expected result is provided
        if (expectedTestResult != null && !EqualityComparer<T>.Default.Equals(expectedTestResult, default(T)))
        {
            if (File.Exists(testInputPath))
            {
                var testInput = InputReader.ReadInput(testInputPath);
                RunTest($"{partName} (Test)", () => solver(testInput), expectedTestResult);
            }
        }

        // Run with real input
        if (File.Exists(realInputPath))
        {
            var realInput = InputReader.ReadInput(realInputPath);
            
            // Check if the input is empty or just whitespace/comments
            if (string.IsNullOrWhiteSpace(realInput) || realInput.StartsWith("#"))
            {
                Console.ForegroundColor = ConsoleColor.DarkYellow;
                Console.WriteLine($"⚠ Real input file is empty or contains placeholder text");
                Console.WriteLine("  Please download your puzzle input from https://adventofcode.com/2025/day/1/input");
                Console.ResetColor();
                return;
            }
            
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.Write($"Running {partName} (Real Input)... ");
            Console.ResetColor();

            try
            {
                var result = solver(realInput);
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"Result: {result}");
                Console.ResetColor();
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"ERROR: {ex.Message}");
                Console.ResetColor();
            }
        }
        else
        {
            Console.ForegroundColor = ConsoleColor.DarkYellow;
            Console.WriteLine($"⚠ Real input file not found: {realInputPath}");
            Console.WriteLine("  Please download your puzzle input from https://adventofcode.com/2025/day/1/input");
            Console.ResetColor();
        }
    }
}
