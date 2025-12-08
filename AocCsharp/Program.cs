using AocCsharp.Day01;
using AocCsharp.Day02;
using AocCsharp.Day03;
using AocCsharp.Day04;
using AocCsharp.Day05;

Console.Clear();
Console.ForegroundColor = ConsoleColor.Green;
Console.WriteLine("╔════════════════════════════════════════════════╗");
Console.WriteLine("║                                                ║");
Console.WriteLine("║      🎄 Advent of Code 2025 🎄                ║");
Console.WriteLine("║         C# Solutions                           ║");
Console.WriteLine("║                                                ║");
Console.WriteLine("╚════════════════════════════════════════════════╝");
Console.ResetColor();
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
            // Add more days here as you implement them
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
