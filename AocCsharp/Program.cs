using AocCsharp.Day01;
using AocCsharp.Day02;
using AocCsharp.Day03;
using AocCsharp.Day04;
using AocCsharp.Day05;
using AocCsharp.Day06;
using AocCsharp.Day07;
using AocCsharp.Day08;
using AocCsharp.Day09;
using AocCsharp.Day10;
using AocCsharp.Day11;
using AocCsharp.Day12;

Console.WriteLine();
Console.WriteLine("==================================================");
Console.WriteLine("🎄 Advent of Code 2025 - C# Solutions 🎄");
Console.WriteLine("==================================================");
Console.WriteLine();

while (true)
{
    Console.ForegroundColor = ConsoleColor.Cyan;
    Console.Write("Select a day (1-25) or 0 to exit: ");
    Console.ResetColor();

    if (!int.TryParse(Console.ReadLine(), out int day))
    {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine("Invalid input. Please enter a number.");
        Console.ResetColor();
        continue;
    }

    if (day == 0)
    {
        Console.ForegroundColor = ConsoleColor.Green;
        Console.WriteLine("\n🎄 Happy Coding! 🎄");
        Console.ResetColor();
        break;
    }

    try
    {
        switch (day)
        {
            case 1:
                Day01.Run();
                break;
            case 2:
                Day02.Run();
                break;
            case 3:
                Day03.Run();
                break;
            case 4:
                Day04.Run();
                break;
            case 5:
                Day05.Run();
                break;
            case 6:
                Day06.Run();
                break;
            case 7:
                Day07.Run();
                break;
            case 8:
                Day08.Run();
                break;
            case 9:
                Day09.Run();
                break;
            case 10:
                Day10.Run();
                break;
            case 11:
                Day11.Run();
                break;
            case 12:
                Day12.Run();
                break;
            default:
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine($"\n⚠ Day {day} not implemented yet!");
                Console.ResetColor();
                break;
        }
    }
    catch (Exception ex)
    {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.WriteLine($"\n✗ Error running Day {day}: {ex.Message}");
        Console.ResetColor();
    }

    Console.WriteLine();
}
