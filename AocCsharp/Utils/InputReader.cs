namespace AocCsharp.Utils;

public static class InputReader
{
    /// <summary>
    /// Reads the entire content of a file as a single string
    /// </summary>
    public static string ReadInput(string filePath)
    {
        if (!File.Exists(filePath))
        {
            throw new FileNotFoundException($"Input file not found: {filePath}");
        }
        return File.ReadAllText(filePath).Trim();
    }

    /// <summary>
    /// Reads a file and returns an array of lines
    /// </summary>
    public static string[] ReadLines(string filePath)
    {
        if (!File.Exists(filePath))
        {
            throw new FileNotFoundException($"Input file not found: {filePath}");
        }
        return File.ReadAllLines(filePath)
            .Where(line => !string.IsNullOrWhiteSpace(line))
            .ToArray();
    }

    /// <summary>
    /// Reads a file and splits content by a delimiter
    /// </summary>
    public static string[] ReadSplit(string filePath, char delimiter = ',')
    {
        var content = ReadInput(filePath);
        return content.Split(delimiter, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
    }
}
