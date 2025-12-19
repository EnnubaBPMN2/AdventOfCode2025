using System;
using System.IO;

var testInput = File.ReadAllText(@"..\inputs\day12_test.txt");
var lines = testInput.Replace("\r", "").Split('\n');

Console.WriteLine($"Total lines: {lines.Length}");
Console.WriteLine("\nLines:");
for (int i = 0; i < lines.Length; i++)
{
    Console.WriteLine($"{i,3}: '{lines[i]}'");
}
