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

    private record Point3D(int X, int Y, int Z);

    public static long Part1(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0) return 0;

        // Parse junction box positions
        var points = new List<Point3D>();
        foreach (var line in lines)
        {
            var parts = line.Split(',');
            if (parts.Length == 3)
            {
                points.Add(new Point3D(
                    int.Parse(parts[0]),
                    int.Parse(parts[1]),
                    int.Parse(parts[2])
                ));
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
                double dist = Math.Sqrt(
                    Math.Pow(p1.X - p2.X, 2) +
                    Math.Pow(p1.Y - p2.Y, 2) +
                    Math.Pow(p1.Z - p2.Z, 2)
                );
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
            if (!circuitSizes.ContainsKey(root))
                circuitSizes[root] = 0;
            circuitSizes[root]++;
        }

        // Get the three largest circuit sizes
        var sizes = circuitSizes.Values.OrderByDescending(x => x).ToList();

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
            var parts = line.Split(',');
            if (parts.Length == 3)
            {
                points.Add(new Point3D(
                    int.Parse(parts[0]),
                    int.Parse(parts[1]),
                    int.Parse(parts[2])
                ));
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
                double dist = Math.Sqrt(
                    Math.Pow(p1.X - p2.X, 2) +
                    Math.Pow(p1.Y - p2.Y, 2) +
                    Math.Pow(p1.Z - p2.Z, 2)
                );
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
                return true; // Actually connected
            }
            return false; // Already connected
        }

        int CountCircuits()
        {
            var roots = new HashSet<int>();
            for (int i = 0; i < n; i++)
            {
                roots.Add(Find(i));
            }
            return roots.Count;
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

                if (CountCircuits() == 1)
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
