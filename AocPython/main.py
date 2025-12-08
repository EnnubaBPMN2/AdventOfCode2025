# Advent of Code 2025 - Python Solutions

from day01.solution import run as run_day01
from day02.solution import run as run_day02
from day03.solution import run as run_day03
from day04.solution import run as run_day04
from day05.solution import run as run_day05
from day06.solution import run as run_day06

def main():
    print("\n" + "="*50)
    print("🎄 Advent of Code 2025 - Python Solutions 🎄")
    print("="*50 + "\n")
    
    while True:
        try:
            day = input("Select a day (1-25) or 0 to exit: ").strip()
            day_num = int(day)
            
            if day_num == 0:
                print("\n🎄 Happy Coding! 🎄\n")
                break
            
            if day_num == 1:
                run_day01()
            # Add more days here as you implement them
            elif day_num == 2:
                run_day02()
            elif day_num == 3:
                run_day03()
            elif day_num == 4:
                run_day04()
            elif day_num == 5:
                run_day05()
            elif day_num == 6:
                run_day06()
            else:
                print(f"\n⚠ Day {day_num} not implemented yet!\n")
                
        except ValueError:
            print("Invalid input. Please enter a number.\n")
        except Exception as e:
            print(f"\n✗ Error: {e}\n")

if __name__ == "__main__":
    main()
