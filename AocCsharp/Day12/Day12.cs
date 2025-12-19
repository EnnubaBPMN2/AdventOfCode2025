using AocCsharp.Utils;

namespace AocCsharp.Day12;

public static class Day12
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day12_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day12.txt");

        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 2);
        Console.WriteLine("\n🎄 Part 2 automatically completed! Both stars earned! 🎄\n");
    }

    public static int Part1(string input)
    {
        var (shapes, regions) = ParseInput(input);

        int count = 0;
        foreach (var region in regions)
        {
            if (CanFitAllPresents(region, shapes))
            {
                count++;
            }
        }

        return count;
    }

    private static (List<List<string>> shapes, List<Region> regions) ParseInput(string input)
    {
        var lines = input.Replace("\r", "").Split('\n');
        var shapes = new List<List<string>>();
        var regions = new List<Region>();

        int i = 0;
        while (i < lines.Length)
        {
            var line = lines[i];

            // Parse region (check this first since it also contains ':')
            if (line.Contains('x') && line.Contains(':'))
            {
                var parts = line.Split(':');
                var dimensions = parts[0].Trim().Split('x');
                int width = int.Parse(dimensions[0]);
                int height = int.Parse(dimensions[1]);

                var counts = parts[1].Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries)
                    .Select(int.Parse).ToArray();

                regions.Add(new Region(width, height, counts));
                i++;
            }
            // Parse shape
            else if (line.Contains(':'))
            {
                var shapeLines = new List<string>();
                i++; // Skip the label line

                while (i < lines.Length && !string.IsNullOrWhiteSpace(lines[i]) && !lines[i].Contains(':'))
                {
                    shapeLines.Add(lines[i]);
                    i++;
                }

                if (shapeLines.Count > 0)
                {
                    shapes.Add(shapeLines);
                }
            }
            else
            {
                i++;
            }
        }

        return (shapes, regions);
    }

    private static int _callCount = 0;

    private static bool CanFitAllPresents(Region region, List<List<string>> shapeTemplates)
    {
        // Quick area check - if total shape area exceeds grid area, impossible
        int totalArea = region.Width * region.Height;
        int requiredArea = 0;

        for (int i = 0; i < region.Counts.Length; i++)
        {
            if (region.Counts[i] > 0)
            {
                int shapeArea = GetShapeArea(shapeTemplates[i]);
                requiredArea += shapeArea * region.Counts[i];
            }
        }

        // If we need more area than available, it's impossible
        if (requiredArea > totalArea)
        {
            return false;
        }

        var grid = new char[region.Height, region.Width];
        for (int r = 0; r < region.Height; r++)
            for (int c = 0; c < region.Width; c++)
                grid[r, c] = '.';

        var presents = new List<(int shapeIndex, int count)>();
        for (int i = 0; i < region.Counts.Length; i++)
        {
            if (region.Counts[i] > 0)
            {
                presents.Add((i, region.Counts[i]));
            }
        }

        _callCount = 0;
        var result = TryPlacePresents(grid, presents, 0, shapeTemplates, 'A');

        return result;
    }

    private static int GetShapeArea(List<string> shape)
    {
        int area = 0;
        foreach (var row in shape)
        {
            area += row.Count(c => c == '#');
        }
        return area;
    }

    private static bool TryPlacePresents(char[,] grid, List<(int shapeIndex, int count)> presents,
        int presentIndex, List<List<string>> shapeTemplates, char label)
    {
        _callCount++;
        if (_callCount > 2000000) return false; // Fail faster on impossible regions

        // Check if all presents are placed
        bool allPlaced = true;
        for (int i = 0; i < presents.Count; i++)
        {
            if (presents[i].count > 0)
            {
                allPlaced = false;
                break;
            }
        }
        if (allPlaced) return true;

        // Try placing first available present type
        for (int i = 0; i < presents.Count; i++)
        {
            if (presents[i].count == 0) continue;

            var (shapeIndex, count) = presents[i];
            var shapes = GetAllOrientations(shapeTemplates[shapeIndex]);

            foreach (var shape in shapes)
            {
                // Try placing at every position
                for (int row = 0; row < grid.GetLength(0); row++)
                {
                    for (int col = 0; col < grid.GetLength(1); col++)
                    {
                        if (CanPlaceShape(grid, shape, row, col))
                        {
                            PlaceShape(grid, shape, row, col, label);

                            // Create new presents list with one less of this shape
                            var newPresents = new List<(int shapeIndex, int count)>(presents);
                            newPresents[i] = (shapeIndex, count - 1);

                            if (TryPlacePresents(grid, newPresents, 0, shapeTemplates, (char)(label + 1)))
                            {
                                return true;
                            }

                            RemoveShape(grid, shape, row, col);
                        }
                    }
                }
            }

            // If we couldn't place this present type anywhere, fail
            return false;
        }

        return true; // All presents placed
    }

    private static List<List<string>> GetAllOrientations(List<string> shape)
    {
        var orientations = new HashSet<string>();
        var current = shape;

        for (int rotation = 0; rotation < 4; rotation++)
        {
            orientations.Add(string.Join("|", current));

            // Also add flipped version
            var flipped = Flip(current);
            orientations.Add(string.Join("|", flipped));

            current = Rotate(current);
        }

        return orientations.Select(s => s.Split('|').ToList()).ToList();
    }

    private static List<string> Rotate(List<string> shape)
    {
        int rows = shape.Count;
        int cols = shape[0].Length;
        var rotated = new List<string>();

        for (int c = 0; c < cols; c++)
        {
            var newRow = new char[rows];
            for (int r = 0; r < rows; r++)
            {
                newRow[r] = shape[rows - 1 - r][c];
            }
            rotated.Add(new string(newRow));
        }

        return rotated;
    }

    private static List<string> Flip(List<string> shape)
    {
        return shape.Select(row => new string(row.Reverse().ToArray())).ToList();
    }

    private static bool CanPlaceShape(char[,] grid, List<string> shape, int startRow, int startCol)
    {
        int gridRows = grid.GetLength(0);
        int gridCols = grid.GetLength(1);

        // Check if the shape fits within grid bounds
        if (startRow + shape.Count > gridRows) return false;
        if (startCol + shape.Max(row => row.Length) > gridCols) return false;

        for (int r = 0; r < shape.Count; r++)
        {
            for (int c = 0; c < shape[r].Length; c++)
            {
                if (shape[r][c] == '#')
                {
                    int gridRow = startRow + r;
                    int gridCol = startCol + c;

                    // Only check '#' cells - '.' cells in the shape can overlap anything
                    if (grid[gridRow, gridCol] != '.')
                    {
                        return false;
                    }
                }
            }
        }

        return true;
    }

    private static void PlaceShape(char[,] grid, List<string> shape, int startRow, int startCol, char label)
    {
        for (int r = 0; r < shape.Count; r++)
        {
            for (int c = 0; c < shape[r].Length; c++)
            {
                if (shape[r][c] == '#')
                {
                    grid[startRow + r, startCol + c] = label;
                }
            }
        }
    }

    private static void RemoveShape(char[,] grid, List<string> shape, int startRow, int startCol)
    {
        for (int r = 0; r < shape.Count; r++)
        {
            for (int c = 0; c < shape[r].Length; c++)
            {
                if (shape[r][c] == '#')
                {
                    grid[startRow + r, startCol + c] = '.';
                }
            }
        }
    }

    private record Region(int Width, int Height, int[] Counts);
}
