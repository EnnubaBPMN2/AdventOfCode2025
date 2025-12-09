using AocCsharp.Utils;

namespace AocCsharp.Day01;

public static class Day01
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day01_test.txt");
        var inputPath = Path.Combine("..", "inputs", "day01.txt");

        // Part 1: Count how many times the dial points at 0
        TestRunner.RunSolution(
            "Part 1",
            Part1,
            testInputPath,
            inputPath,
            expectedTestResult: 3
        );

        // Part 2: To be unlocked after completing Part 1
        TestRunner.RunSolution(
            "Part 2",
            Part2,
            testInputPath,
            inputPath,
            expectedTestResult: 6
        );
    }

    public static int Part1(string input)
    {
        // Parse the rotations (handle spaces and newlines)
        var rotations = input.Split(new[] { ' ', '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
        
        int position = 50;  // Starting position
        int zeroCount = 0;

        foreach (var rotation in rotations)
        {
            var direction = rotation[0];
            var distance = int.Parse(rotation.Substring(1));

            if (direction == 'L')
            {
                position = (position - distance) % 100;
                if (position < 0) position += 100;
            }
            else if (direction == 'R')
            {
                position = (position + distance) % 100;
            }

            if (position == 0)
            {
                zeroCount++;
            }
        }

        return zeroCount;
    }

    public static int Part2(string input)
    {
        // Parse the rotations (handle spaces and newlines)
        var rotations = input.Split(new[] { ' ', '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
        
        int position = 50;  // Starting position
        int zeroCount = 0;

        foreach (var rotation in rotations)
        {
            var direction = rotation[0];
            var distance = int.Parse(rotation.Substring(1));

            if (direction == 'R')
            {
                // Moving right: count multiples of 100 in range (position, position + distance]
                // Equivalent to floor((pos + dist) / 100)
                zeroCount += (position + distance) / 100;
                position = (position + distance) % 100;
            }
            else if (direction == 'L')
            {
                // Moving left: count multiples of 100 in range [position - distance, position)
                // We use floor division logic. 
                // Count = floor((pos - 1) / 100) - floor((pos - dist - 1) / 100)
                
                // Since pos is always [0, 99], floor((pos - 1) / 100) is:
                // 0 if pos > 0
                // -1 if pos == 0
                int startFloor = (position - 1) < 0 ? -1 : 0;
                int endFloor = (int)Math.Floor((double)(position - distance - 1) / 100);
                
                zeroCount += startFloor - endFloor;
                
                position = (position - distance) % 100;
                if (position < 0) position += 100;
            }
        }

        return zeroCount;
    }
}
