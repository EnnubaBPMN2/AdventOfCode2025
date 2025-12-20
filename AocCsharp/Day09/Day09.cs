using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using AocCsharp.Utils;

namespace AocCsharp.Day09;

public static class Day09
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day09_test.txt");
        var realInputPath = Path.Combine("..", "inputs", "day09.txt");

        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 50L);
        TestRunner.RunSolution("Part 2", Part2, testInputPath, realInputPath, expectedTestResult: 24L);
    }

    public static long Part1(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0) return 0;

        var redTiles = new List<(int X, int Y)>();
        foreach (var line in lines)
        {
            int commaIndex = line.IndexOf(',');
            if (commaIndex > 0)
            {
                var xSpan = line.AsSpan(0, commaIndex).Trim();
                var ySpan = line.AsSpan(commaIndex + 1).Trim();
                if (int.TryParse(xSpan, out int x) && int.TryParse(ySpan, out int y))
                {
                    redTiles.Add((x, y));
                }
            }
        }

        if (redTiles.Count < 2) return 0;

        long maxArea = 0;

        for (int i = 0; i < redTiles.Count; i++)
        {
            for (int j = i + 1; j < redTiles.Count; j++)
            {
                var tile1 = redTiles[i];
                var tile2 = redTiles[j];

                int width = Math.Abs(tile2.X - tile1.X) + 1;
                int height = Math.Abs(tile2.Y - tile1.Y) + 1;
                long area = (long)width * height;

                maxArea = Math.Max(maxArea, area);
            }
        }

        return maxArea;
    }

    public static long Part2(string input)
    {
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);
        if (lines.Length == 0) return 0;

        var redTiles = new List<(int X, int Y)>();
        foreach (var line in lines)
        {
            int commaIndex = line.IndexOf(',');
            if (commaIndex > 0)
            {
                var xSpan = line.AsSpan(0, commaIndex).Trim();
                var ySpan = line.AsSpan(commaIndex + 1).Trim();
                if (int.TryParse(xSpan, out int x) && int.TryParse(ySpan, out int y))
                {
                    redTiles.Add((x, y));
                }
            }
        }

        if (redTiles.Count < 2) return 0;

        // Pre-compute tile set for fast lookup
        var tileSet = new HashSet<(int, int)>(redTiles);
        int n = redTiles.Count;

        long maxArea = 0;

        for (int i = 0; i < n; i++)
        {
            for (int j = i + 1; j < n; j++)
            {
                var tile1 = redTiles[i];
                var tile2 = redTiles[j];

                int rectMinX = Math.Min(tile1.X, tile2.X);
                int rectMaxX = Math.Max(tile1.X, tile2.X);
                int rectMinY = Math.Min(tile1.Y, tile2.Y);
                int rectMaxY = Math.Max(tile1.Y, tile2.Y);

                if (!IsInsideOrOnBoundaryFast((rectMinX, rectMinY), redTiles, tileSet)) continue;
                if (!IsInsideOrOnBoundaryFast((rectMinX, rectMaxY), redTiles, tileSet)) continue;
                if (!IsInsideOrOnBoundaryFast((rectMaxX, rectMinY), redTiles, tileSet)) continue;
                if (!IsInsideOrOnBoundaryFast((rectMaxX, rectMaxY), redTiles, tileSet)) continue;

                bool hasInteriorTile = false;
                for (int k = 0; k < n && !hasInteriorTile; k++)
                {
                    var tile = redTiles[k];
                    if (tile.X > rectMinX && tile.X < rectMaxX && tile.Y > rectMinY && tile.Y < rectMaxY)
                    {
                        hasInteriorTile = true;
                    }
                }

                if (hasInteriorTile) continue;

                bool hasCrossing = false;
                for (int k = 0; k < n && !hasCrossing; k++)
                {
                    var p1 = redTiles[k];
                    var p2 = redTiles[(k + 1) % n];

                    if (SegmentsProperlyIntersect(p1, p2, (rectMinX, rectMinY), (rectMaxX, rectMinY)) ||
                        SegmentsProperlyIntersect(p1, p2, (rectMinX, rectMaxY), (rectMaxX, rectMaxY)) ||
                        SegmentsProperlyIntersect(p1, p2, (rectMinX, rectMinY), (rectMinX, rectMaxY)) ||
                        SegmentsProperlyIntersect(p1, p2, (rectMaxX, rectMinY), (rectMaxX, rectMaxY)))
                    {
                        hasCrossing = true;
                    }
                }

                if (!hasCrossing)
                {
                    long width = rectMaxX - rectMinX + 1;
                    long height = rectMaxY - rectMinY + 1;
                    long area = width * height;
                    maxArea = Math.Max(maxArea, area);
                }
            }
        }

        return maxArea;
    }

    private static bool IsInsideOrOnBoundaryFast((int X, int Y) point, List<(int X, int Y)> polygon, HashSet<(int, int)> tileSet)
    {
        // Fast path: check if point is one of the tiles
        if (tileSet.Contains(point))
        {
            return true;
        }

        // Check if point is on any edge
        int n = polygon.Count;
        for (int i = 0; i < n; i++)
        {
            var p1 = polygon[i];
            var p2 = polygon[(i + 1) % n];

            if (IsPointOnSegment(point, p1, p2))
            {
                return true;
            }
        }

        return IsInsidePolygon(point, polygon);
    }

    private static bool IsInsideOrOnBoundary((int X, int Y) point, List<(int X, int Y)> polygon)
    {
        for (int i = 0; i < polygon.Count; i++)
        {
            var p1 = polygon[i];
            var p2 = polygon[(i + 1) % polygon.Count];

            if (IsPointOnSegment(point, p1, p2))
            {
                return true;
            }
        }

        return IsInsidePolygon(point, polygon);
    }

    private static bool IsPointOnSegment((int X, int Y) point, (int X, int Y) p1, (int X, int Y) p2)
    {
        if (p1.X == p2.X && p1.X == point.X)
        {
            int minY = Math.Min(p1.Y, p2.Y);
            int maxY = Math.Max(p1.Y, p2.Y);
            return point.Y >= minY && point.Y <= maxY;
        }
        if (p1.Y == p2.Y && p1.Y == point.Y)
        {
            int minX = Math.Min(p1.X, p2.X);
            int maxX = Math.Max(p1.X, p2.X);
            return point.X >= minX && point.X <= maxX;
        }
        return false;
    }

    private static bool IsInsidePolygon((int X, int Y) point, List<(int X, int Y)> polygon)
    {
        int intersections = 0;
        int n = polygon.Count;

        for (int i = 0; i < n; i++)
        {
            var p1 = polygon[i];
            var p2 = polygon[(i + 1) % n];

            if ((p1.Y > point.Y) != (p2.Y > point.Y))
            {
                double intersectX = (double)(p2.X - p1.X) * (point.Y - p1.Y) / (p2.Y - p1.Y) + p1.X;
                if (point.X < intersectX)
                {
                    intersections++;
                }
            }
        }

        return (intersections % 2) == 1;
    }

    private static bool SegmentsProperlyIntersect((int X, int Y) p1, (int X, int Y) p2,
        (int X, int Y) p3, (int X, int Y) p4)
    {
        int d1 = Direction(p3, p4, p1);
        int d2 = Direction(p3, p4, p2);
        int d3 = Direction(p1, p2, p3);
        int d4 = Direction(p1, p2, p4);

        if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
            ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0)))
        {
            return true;
        }

        return false;
    }

    private static int Direction((int X, int Y) p1, (int X, int Y) p2, (int X, int Y) p3)
    {
        long val = (long)(p3.Y - p1.Y) * (p2.X - p1.X) - (long)(p2.Y - p1.Y) * (p3.X - p1.X);
        if (val == 0) return 0;
        return (val > 0) ? 1 : -1;
    }
}
