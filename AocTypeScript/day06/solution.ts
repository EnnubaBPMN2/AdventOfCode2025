import { runSolution } from "../utils/runner.ts";

function parseGrid(input: string): string[][] {
  const lines = input.replace(/\r\n/g, "\n").split("\n");
  const filteredLines: string[] = [];
  let maxWidth = 0;
  for (const line of lines) {
    if (line.trim() !== "" || filteredLines.length > 0) {
      filteredLines.push(line);
      if (line.length > maxWidth) {
        maxWidth = line.length;
      }
    }
  }

  // Remove trailing empty lines
  while (filteredLines.length > 0 && filteredLines[filteredLines.length - 1].trim() === "") {
    filteredLines.pop();
  }

  return filteredLines.map((line) => {
    return line.padEnd(maxWidth, " ").split("");
  });
}

function findBlocks(grid: string[][]): { startCol: number; endCol: number }[] {
  if (grid.length === 0) return [];
  const width = grid[0].length;
  const height = grid.length;
  const blocks: { startCol: number; endCol: number }[] = [];

  let start = -1;
  for (let col = 0; col < width; col++) {
    let isEmpty = true;
    for (let row = 0; row < height; row++) {
      if (grid[row][col] !== " ") {
        isEmpty = false;
        break;
      }
    }

    if (!isEmpty) {
      if (start === -1) start = col;
    } else {
      if (start !== -1) {
        blocks.push({ startCol: start, endCol: col - 1 });
        start = -1;
      }
    }
  }
  if (start !== -1) {
    blocks.push({ startCol: start, endCol: width - 1 });
  }
  return blocks;
}

export function part1(input: string): number {
  const grid = parseGrid(input);
  if (grid.length < 2) return 0;
  const blocks = findBlocks(grid);
  const height = grid.length;
  let total = 0;

  for (const b of blocks) {
    let op = "+";
    for (let col = b.startCol; col <= b.endCol; col++) {
      const char = grid[height - 1][col];
      if (char === "+" || char === "*") {
        op = char;
        break;
      }
    }

    const numbers: number[] = [];
    for (let row = 0; row < height - 1; row++) {
      const numStr = grid[row].slice(b.startCol, b.endCol + 1).join("").trim();
      if (numStr !== "") {
        numbers.push(parseInt(numStr));
      }
    }

    if (numbers.length > 0) {
      let res = numbers[0];
      for (let i = 1; i < numbers.length; i++) {
        if (op === "+") res += numbers[i];
        else res *= numbers[i];
      }
      total += res;
    }
  }

  return total;
}

export function part2(input: string): number {
  const grid = parseGrid(input);
  if (grid.length < 2) return 0;
  const blocks = findBlocks(grid);
  const height = grid.length;
  let total = 0;

  for (const b of blocks) {
    let op = "+";
    for (let col = b.startCol; col <= b.endCol; col++) {
      const char = grid[height - 1][col];
      if (char === "+" || char === "*") {
        op = char;
        break;
      }
    }

    const numbers: number[] = [];
    for (let col = b.endCol; col >= b.startCol; col--) {
      let numStr = "";
      for (let row = 0; row < height - 1; row++) {
        if (grid[row][col] !== " ") {
          numStr += grid[row][col];
        }
      }
      if (numStr !== "") {
        numbers.push(parseInt(numStr));
      }
    }

    if (numbers.length > 0) {
      let res = numbers[0];
      for (let i = 1; i < numbers.length; i++) {
        if (op === "+") res += numbers[i];
        else res *= numbers[i];
      }
      total += res;
    }
  }

  return total;
}

export function run() {
  const testPath = "../inputs/day06_test.txt";
  const realPath = "../inputs/day06.txt";

  runSolution("Part 1", part1, testPath, realPath, 4277556);
  runSolution("Part 2", part2, testPath, realPath, 3263827);
}
