using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using AocCsharp.Utils;

namespace AocCsharp.Day08;

public static class Day08
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day08_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day08.txt");

        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 40);
        TestRunner.RunSolution("Part 2", Part2, testInputPath, realInputPath, expectedTestResult: 25272);
    }

    private readonly struct Point3D
    {
        public readonly int X;
        public readonly int Y;
        public readonly int Z;

        public Point3D(int x, int y, int z)
        {
            X = x;
            Y = y;
            Z = z;
        }
    }

    public static long Part1(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0) return 0;

        // Parse junction box positions
        var points = new List<Point3D>();
        foreach (var line in lines)
        {
            int firstComma = line.IndexOf(',');
            if (firstComma > 0)
            {
                int secondComma = line.IndexOf(',', firstComma + 1);
                if (secondComma > firstComma)
                {
                    if (int.TryParse(line.AsSpan(0, firstComma), out int x) &&
                        int.TryParse(line.AsSpan(firstComma + 1, secondComma - firstComma - 1), out int y) &&
                        int.TryParse(line.AsSpan(secondComma + 1), out int z))
                    {
                        points.Add(new Point3D(x, y, z));
                    }
                }
            }
        }

        int n = points.Count;

        // Calculate all pairwise distances
        var distances = new List<(double Distance, int I, int J)>();
        for (int i = 0; i < n; i++)
        {
            for (int j = i + 1; j < n; j++)
            {
                var p1 = points[i];
                var p2 = points[j];
                long dx = p1.X - p2.X;
                long dy = p1.Y - p2.Y;
                long dz = p1.Z - p2.Z;
                double dist = Math.Sqrt(dx * dx + dy * dy + dz * dz);
                distances.Add((dist, i, j));
            }
        }

        // Sort by distance (shortest first)
        distances.Sort((a, b) => a.Distance.CompareTo(b.Distance));

        // Union-Find data structure
        var parent = new int[n];
        var size = new int[n];
        for (int i = 0; i < n; i++)
        {
            parent[i] = i;
            size[i] = 1;
        }

        int Find(int x)
        {
            if (parent[x] != x)
                parent[x] = Find(parent[x]);
            return parent[x];
        }

        void Union(int x, int y)
        {
            int rootX = Find(x);
            int rootY = Find(y);
            if (rootX != rootY)
            {
                // Union by size
                if (size[rootX] < size[rootY])
                {
                    parent[rootX] = rootY;
                    size[rootY] += size[rootX];
                }
                else
                {
                    parent[rootY] = rootX;
                    size[rootX] += size[rootY];
                }
            }
        }

        // Connect the 1000 shortest pairs (or 10 for test input)
        int connectionsToMake = n == 20 ? 10 : 1000;
        int connectionsMade = 0;

        foreach (var (dist, i, j) in distances)
        {
            if (connectionsMade >= connectionsToMake) break;

            // Always try to connect (Union-Find handles already-connected case)
            int rootI = Find(i);
            int rootJ = Find(j);

            Union(i, j);
            connectionsMade++;
        }

        // Find all unique circuits and their sizes
        var circuitSizes = new Dictionary<int, int>();
        for (int i = 0; i < n; i++)
        {
            int root = Find(i);
            circuitSizes.TryGetValue(root, out int count);
            circuitSizes[root] = count + 1;
        }

        // Get the three largest circuit sizes
        var sizes = new List<int>(circuitSizes.Values);
        sizes.Sort((a, b) => b.CompareTo(a)); // Descending

        if (sizes.Count >= 3)
        {
            return (long)sizes[0] * sizes[1] * sizes[2];
        }
        else if (sizes.Count == 2)
        {
            return (long)sizes[0] * sizes[1];
        }
        else if (sizes.Count == 1)
        {
            return sizes[0];
        }

        return 0;
    }

    public static long Part2(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0) return 0;

        // Parse junction box positions
        var points = new List<Point3D>();
        foreach (var line in lines)
        {
            int firstComma = line.IndexOf(',');
            if (firstComma > 0)
            {
                int secondComma = line.IndexOf(',', firstComma + 1);
                if (secondComma > firstComma)
                {
                    if (int.TryParse(line.AsSpan(0, firstComma), out int x) &&
                        int.TryParse(line.AsSpan(firstComma + 1, secondComma - firstComma - 1), out int y) &&
                        int.TryParse(line.AsSpan(secondComma + 1), out int z))
                    {
                        points.Add(new Point3D(x, y, z));
                    }
                }
            }
        }

        int n = points.Count;

        // Calculate all pairwise distances
        var distances = new List<(double Distance, int I, int J)>();
        for (int i = 0; i < n; i++)
        {
            for (int j = i + 1; j < n; j++)
            {
                var p1 = points[i];
                var p2 = points[j];
                long dx = p1.X - p2.X;
                long dy = p1.Y - p2.Y;
                long dz = p1.Z - p2.Z;
                double dist = Math.Sqrt(dx * dx + dy * dy + dz * dz);
                distances.Add((dist, i, j));
            }
        }

        // Sort by distance (shortest first)
        distances.Sort((a, b) => a.Distance.CompareTo(b.Distance));

        // Union-Find data structure
        var parent = new int[n];
        var size = new int[n];
        for (int i = 0; i < n; i++)
        {
            parent[i] = i;
            size[i] = 1;
        }

        int Find(int x)
        {
            if (parent[x] != x)
                parent[x] = Find(parent[x]);
            return parent[x];
        }

        // Track number of circuits - starts at n (each node is its own circuit)
        int circuitCount = n;

        bool Union(int x, int y)
        {
            int rootX = Find(x);
            int rootY = Find(y);
            if (rootX != rootY)
            {
                // Union by size
                if (size[rootX] < size[rootY])
                {
                    parent[rootX] = rootY;
                    size[rootY] += size[rootX];
                }
                else
                {
                    parent[rootY] = rootX;
                    size[rootX] += size[rootY];
                }
                circuitCount--; // Merged two circuits into one
                return true; // Actually connected
            }
            return false; // Already connected
        }

        // Connect pairs until there's only one circuit
        int lastI = -1, lastJ = -1;
        foreach (var (dist, i, j) in distances)
        {
            if (Union(i, j))
            {
                // This connection actually merged two circuits
                lastI = i;
                lastJ = j;

                if (circuitCount == 1)
                {
                    // All connected!
                    break;
                }
            }
        }

        // Multiply X coordinates of last two connected junction boxes
        if (lastI >= 0 && lastJ >= 0)
        {
            return (long)points[lastI].X * points[lastJ].X;
        }

        return 0;
    }
}
