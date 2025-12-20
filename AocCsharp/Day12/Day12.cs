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

        // Precompute all shape orientations once
        var allOrientations = new Shape[shapes.Count][];
        for (int i = 0; i < shapes.Count; i++)
        {
            allOrientations[i] = GetAllOrientations(shapes[i]);
        }

        int count = 0;
        foreach (var region in regions)
        {
            if (CanFitAllPresents(region, allOrientations))
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

                var countParts = parts[1].Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
                var counts = new int[countParts.Length];
                for (int j = 0; j < countParts.Length; j++)
                {
                    counts[j] = int.Parse(countParts[j]);
                }

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

    private static bool CanFitAllPresents(Region region, Shape[][] allOrientations)
    {
        // Quick area check
        int totalArea = region.Width * region.Height;
        int requiredArea = 0;

        for (int i = 0; i < region.Counts.Length; i++)
        {
            if (region.Counts[i] > 0)
            {
                int shapeArea = allOrientations[i][0].Area;
                requiredArea += shapeArea * region.Counts[i];
            }
        }

        if (requiredArea > totalArea)
        {
            return false;
        }

        var grid = new bool[region.Height * region.Width];
        var counts = new int[region.Counts.Length];
        Array.Copy(region.Counts, counts, region.Counts.Length);

        return TryPlacePresents(grid, region.Width, region.Height, counts, allOrientations, 0);
    }

    private static bool TryPlacePresents(bool[] grid, int width, int height, int[] counts,
        Shape[][] allOrientations, int callCount)
    {
        if (callCount > 2000000) return false;

        // Check if all presents are placed
        bool allPlaced = true;
        for (int i = 0; i < counts.Length; i++)
        {
            if (counts[i] > 0)
            {
                allPlaced = false;
                break;
            }
        }
        if (allPlaced) return true;

        // Try placing first available present type
        for (int shapeIdx = 0; shapeIdx < counts.Length; shapeIdx++)
        {
            if (counts[shapeIdx] == 0) continue;

            var orientations = allOrientations[shapeIdx];

            // Try each orientation at each position
            foreach (var shape in orientations)
            {
                for (int row = 0; row <= height - shape.Height; row++)
                {
                    for (int col = 0; col <= width - shape.Width; col++)
                    {
                        if (CanPlaceShape(grid, width, height, shape, row, col))
                        {
                            PlaceShape(grid, width, shape, row, col);
                            counts[shapeIdx]--;

                            if (TryPlacePresents(grid, width, height, counts, allOrientations, callCount + 1))
                            {
                                return true;
                            }

                            RemoveShape(grid, width, shape, row, col);
                            counts[shapeIdx]++;
                        }
                    }
                }
            }

            // If we couldn't place this present type anywhere, fail
            return false;
        }

        return true;
    }

    private static bool CanPlaceShape(bool[] grid, int width, int height, Shape shape, int startRow, int startCol)
    {
        if (startRow + shape.Height > height) return false;
        if (startCol + shape.Width > width) return false;

        for (int i = 0; i < shape.CellCount; i++)
        {
            int r = shape.Rows[i];
            int c = shape.Cols[i];
            int gridIdx = (startRow + r) * width + (startCol + c);

            if (grid[gridIdx])
            {
                return false;
            }
        }

        return true;
    }

    private static void PlaceShape(bool[] grid, int width, Shape shape, int startRow, int startCol)
    {
        for (int i = 0; i < shape.CellCount; i++)
        {
            int r = shape.Rows[i];
            int c = shape.Cols[i];
            int gridIdx = (startRow + r) * width + (startCol + c);
            grid[gridIdx] = true;
        }
    }

    private static void RemoveShape(bool[] grid, int width, Shape shape, int startRow, int startCol)
    {
        for (int i = 0; i < shape.CellCount; i++)
        {
            int r = shape.Rows[i];
            int c = shape.Cols[i];
            int gridIdx = (startRow + r) * width + (startCol + c);
            grid[gridIdx] = false;
        }
    }

    private static Shape[] GetAllOrientations(List<string> shapeTemplate)
    {
        var orientations = new HashSet<string>();
        var current = shapeTemplate;

        for (int rotation = 0; rotation < 4; rotation++)
        {
            var key = string.Join("|", current);
            orientations.Add(key);

            var flipped = Flip(current);
            var flippedKey = string.Join("|", flipped);
            orientations.Add(flippedKey);

            current = Rotate(current);
        }

        var result = new Shape[orientations.Count];
        int idx = 0;
        foreach (var s in orientations)
        {
            result[idx++] = new Shape(s.Split('|'));
        }
        return result;
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
        var flipped = new List<string>(shape.Count);
        for (int i = 0; i < shape.Count; i++)
        {
            var row = shape[i];
            var chars = new char[row.Length];
            for (int j = 0; j < row.Length; j++)
            {
                chars[j] = row[row.Length - 1 - j];
            }
            flipped.Add(new string(chars));
        }
        return flipped;
    }

    private record Region(int Width, int Height, int[] Counts);

    private class Shape
    {
        public int[] Rows;
        public int[] Cols;
        public int CellCount;
        public int Width;
        public int Height;
        public int Area;

        public Shape(string[] lines)
        {
            var cells = new List<(int row, int col)>();

            for (int r = 0; r < lines.Length; r++)
            {
                for (int c = 0; c < lines[r].Length; c++)
                {
                    if (lines[r][c] == '#')
                    {
                        cells.Add((r, c));
                    }
                }
            }

            CellCount = cells.Count;
            Rows = new int[CellCount];
            Cols = new int[CellCount];

            for (int i = 0; i < CellCount; i++)
            {
                Rows[i] = cells[i].row;
                Cols[i] = cells[i].col;
            }

            Height = lines.Length;
            Width = 0;
            for (int i = 0; i < lines.Length; i++)
            {
                if (lines[i].Length > Width) Width = lines[i].Length;
            }
            Area = CellCount;
        }
    }
}
