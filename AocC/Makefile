CC = /c/Users/HermannRosch/AppData/Local/Microsoft/WinGet/Packages/BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe/mingw64/bin/gcc.exe
CFLAGS = -std=c17 -Wall -Wextra -O2
LDFLAGS = -lm

SRCS = main.c runner.c input.c \
       day01.c day02.c day03.c day04.c day05.c day06.c \
       day07.c day08.c day09.c day10.c day11.c day12.c
OBJS = $(SRCS:.c=.o)
TARGET = aoc2025

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(TARGET) $(TARGET).exe

.PHONY: all clean
