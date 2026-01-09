#include <stdio.h>
#include <stdlib.h>

// Day function declarations
#include "day01.h"
#include "day02.h"
#include "day03.h"
#include "day04.h"
#include "day05.h"
#include "day06.h"
#include "day07.h"
#include "day08.h"
#include "day09.h"
#include "day10.h"
#include "day11.h"
#include "day12.h"

// ANSI color codes
#define COLOR_RESET   "\033[0m"
#define COLOR_CYAN    "\033[36m"
#define COLOR_GREEN   "\033[32m"
#define COLOR_RED     "\033[31m"
#define COLOR_YELLOW  "\033[33m"

int main(void) {
    printf("\n");
    printf("==================================================\n");
    printf("🎄 Advent of Code 2025 - C Solutions 🎄\n");
    printf("==================================================\n");
    printf("\n");

    while (1) {
        printf(COLOR_CYAN "Select a day (1-25) or 0 to exit: " COLOR_RESET);
        fflush(stdout);

        int day;
        if (scanf("%d", &day) != 1) {
            // Clear invalid input
            int c;
            while ((c = getchar()) != '\n' && c != EOF);
            printf(COLOR_RED "Invalid input. Please enter a number." COLOR_RESET "\n");
            continue;
        }

        if (day == 0) {
            printf("\n" COLOR_GREEN "🎄 Happy Coding! 🎄" COLOR_RESET "\n");
            break;
        }

        switch (day) {
            case 1:  day01_run(); break;
            case 2:  day02_run(); break;
            case 3:  day03_run(); break;
            case 4:  day04_run(); break;
            case 5:  day05_run(); break;
            case 6:  day06_run(); break;
            case 7:  day07_run(); break;
            case 8:  day08_run(); break;
            case 9:  day09_run(); break;
            case 10: day10_run(); break;
            case 11: day11_run(); break;
            case 12: day12_run(); break;
            default:
                printf("\n" COLOR_YELLOW "⚠ Day %d not implemented yet!" COLOR_RESET "\n", day);
                break;
        }

        printf("\n");
    }

    return 0;
}
