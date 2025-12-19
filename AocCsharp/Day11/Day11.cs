using AocCsharp.Utils;

namespace AocCsharp.Day11;

public static class Day11
{
    public static void Run()
    {
        var testInputPath = Path.Combine("..", "inputs", "day11_test.txt");
        var testInputPath2 = Path.Combine("..", "inputs", "day11_test_part2.txt");
        var realInputPath = Path.Combine("..", "inputs", "day11.txt");

        TestRunner.RunSolution("Part 1", Part1, testInputPath, realInputPath, expectedTestResult: 5);
        TestRunner.RunSolution("Part 2", Part2, testInputPath2, realInputPath, expectedTestResult: 2);
    }

    public static int Part1(string input)
    {
        var graph = ParseGraph(input);
        return CountPaths(graph, "you", "out");
    }

    public static long Part2(string input)
    {
        var graph = ParseGraph(input);
        return CountPathsWithRequiredNodes(graph, "svr", "out", new[] { "dac", "fft" });
    }

    private static Dictionary<string, List<string>> ParseGraph(string input)
    {
        var graph = new Dictionary<string, List<string>>();
        var lines = input.Replace("\r", "").Split('\n', StringSplitOptions.RemoveEmptyEntries);

        foreach (var line in lines)
        {
            var parts = line.Split(':', StringSplitOptions.TrimEntries);
            if (parts.Length != 2) continue;

            string node = parts[0];
            var connections = parts[1].Split(' ', StringSplitOptions.RemoveEmptyEntries).ToList();

            graph[node] = connections;
        }

        return graph;
    }

    private static int CountPaths(Dictionary<string, List<string>> graph, string start, string end)
    {
        int pathCount = 0;
        var visited = new HashSet<string>();

        void DFS(string current)
        {
            // If we've reached the end, count this path
            if (current == end)
            {
                pathCount++;
                return;
            }

            // Mark current node as visited
            visited.Add(current);

            // If this node has outgoing connections, explore them
            if (graph.ContainsKey(current))
            {
                foreach (var next in graph[current])
                {
                    // Only visit nodes we haven't visited in this path
                    if (!visited.Contains(next))
                    {
                        DFS(next);
                    }
                }
            }

            // Backtrack: unmark current node for other paths
            visited.Remove(current);
        }

        DFS(start);
        return pathCount;
    }

    private static long CountPathsWithRequiredNodes(Dictionary<string, List<string>> graph, string start, string end, string[] requiredNodes)
    {
        // Build index map for required nodes
        var requiredIndex = new Dictionary<string, int>();
        for (int i = 0; i < requiredNodes.Length; i++)
        {
            requiredIndex[requiredNodes[i]] = i;
        }

        var visited = new HashSet<string>();
        var memo = new Dictionary<(string, int), long>();

        long DFS(string current, int visitedRequiredBitmask)
        {
            // If we've reached the end, check if all required nodes were visited
            if (current == end)
            {
                // Check if all required nodes have been visited (all bits set)
                return (visitedRequiredBitmask == (1 << requiredNodes.Length) - 1) ? 1 : 0;
            }

            // Check memoization (only when not in visited set to avoid cycle issues)
            var key = (current, visitedRequiredBitmask);
            if (!visited.Contains(current) && memo.ContainsKey(key))
            {
                return memo[key];
            }

            // Mark current node as visited (for cycle detection)
            visited.Add(current);

            // Track if this is a required node
            int newVisitedRequiredBitmask = visitedRequiredBitmask;
            if (requiredIndex.TryGetValue(current, out int idx))
            {
                newVisitedRequiredBitmask |= (1 << idx);
            }

            long count = 0;

            // If this node has outgoing connections, explore them
            if (graph.ContainsKey(current))
            {
                foreach (var next in graph[current])
                {
                    // Only visit nodes we haven't visited in this path
                    if (!visited.Contains(next))
                    {
                        count += DFS(next, newVisitedRequiredBitmask);
                    }
                }
            }

            // Backtrack: unmark current node for other paths
            visited.Remove(current);

            // Memoize the result
            if (!visited.Contains(current))
            {
                memo[key] = count;
            }

            return count;
        }

        return DFS(start, 0);
    }
}
