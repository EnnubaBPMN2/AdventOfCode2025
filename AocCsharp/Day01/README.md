# Day 01: Secret Entrance

[Advent of Code 2025 - Day 1](https://adventofcode.com/2025/day/1)

## Problem Summary

You need to access the North Pole base, but the password has been changed. The password is locked in a safe with a combination dial numbered 0-99. However, the safe is a decoy - the actual password is **the number of times the dial points at 0** after following a sequence of rotation instructions.

### The Dial

- Numbers 0 through 99 arranged in a circle
- Starts at position **50**
- Rotations wrap around (0 ↔ 99)

### Rotation Instructions

Each rotation is formatted as:
- **L** = rotate left (toward lower numbers)
- **R** = rotate right (toward higher numbers)
- Followed by a distance (number of clicks)

**Examples:**
- From position 11: `R8` → position 19
- From position 19: `L19` → position 0
- From position 5: `L10` → position 95 (wraps around)

### Goal

Count how many times the dial lands on **0** after each rotation in the sequence.

## Example

**Input:**
```
L68 L30 R48 L5 R60 L55 L1 L99 R14 L82
```

**Dial Movement:**
1. Start: **50**
2. L68 → 82
3. L30 → 52
4. R48 → **0** ✓ (count: 1)
5. L5 → 95
6. R60 → 55
7. L55 → **0** ✓ (count: 2)
8. L1 → 99
9. L99 → **0** ✓ (count: 3)
10. R14 → 14
11. L82 → 32

**Answer:** `3` (dial pointed at 0 three times)

## Solution Implementation

### Part 1

**Algorithm:**
1. Parse space-separated rotation instructions
2. Start at position 50
3. For each rotation:
   - Extract direction (L/R) and distance
   - Update position using modulo arithmetic for wrapping
   - If position equals 0, increment counter
4. Return the count

**Key Implementation Details:**
- Uses modulo 100 for circular wrapping
- Handles negative positions for left rotations
- Splits input by spaces to parse individual rotations

### Part 2

🔒 **Locked** - Will be unlocked after completing Part 1

## Running the Solution

### From the AocCsharp directory:

```powershell
dotnet run
# Select day 1 when prompted
```

### Direct execution:

```powershell
cd C:\Users\HermannRosch\source\repos\EnnubaBPMN2\AdventOfCode2025\AocCsharp
dotnet run
```

## Files

- **[Day01.cs](Day01.cs)** - Solution implementation
- **[test_input.txt](test_input.txt)** - Example input (expected result: 3)
- **[input.txt](input.txt)** - Your puzzle input (download from [adventofcode.com](https://adventofcode.com/2025/day/1/input))

## Test Results

✅ **Test Input:** PASSED (Result: 3)

## Code Structure

```csharp
public static int Part1(string input)
{
    var rotations = input.Split(' ', StringSplitOptions.RemoveEmptyEntries);
    int position = 50;  // Starting position
    int zeroCount = 0;

    foreach (var rotation in rotations)
    {
        var direction = rotation[0];
        var distance = int.Parse(rotation.Substring(1));

        if (direction == 'L')
        {
            position = (position - distance) % 100;
            if (position < 0) position += 100;
        }
        else if (direction == 'R')
        {
            position = (position + distance) % 100;
        }

        if (position == 0)
        {
            zeroCount++;
        }
    }

    return zeroCount;
}
```

## Notes

- The safe is a **decoy** - don't try to actually open it with the rotations
- The password is the **count** of zero positions, not the final position
- Modulo arithmetic handles the circular nature of the dial
- Both left and right rotations can land on 0

## Next Steps

1. Download your puzzle input from https://adventofcode.com/2025/day/1/input
2. Paste it into `input.txt`
3. Run the solution to get your answer
4. Submit your answer to unlock Part 2
5. Implement Part 2 solution when available

---

**Status:** Part 1 ✅ Complete | Part 2 🔒 Locked
