import { runSolution } from "../utils/runner.js";

const DR = [-1, -1, 0, 1, 1, 1, 0, -1];
const DC = [0, 1, 1, 1, 0, -1, -1, -1];

function parseGrid(input) {
  return input
    .trim()
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line !== "")
    .map((line) => line.split(""));
}

function countNeighbors(grid, r, c) {
  const rows = grid.length;
  const cols = grid[0].length;
  let count = 0;
  for (let i = 0; i < 8; i++) {
    const nr = r + DR[i];
    const nc = c + DC[i];
    if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
      if (grid[nr][nc] === "@") {
        count++;
      }
    }
  }
  return count;
}

export function part1(input) {
  const grid = parseGrid(input);
  if (grid.length === 0) return 0;

  const rows = grid.length;
  const cols = grid[0].length;
  let accessible = 0;

  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      if (grid[r][c] === "@") {
        if (countNeighbors(grid, r, c) < 4) {
          accessible++;
        }
      }
    }
  }

  return accessible;
}

export function part2(input) {
  const grid = parseGrid(input);
  if (grid.length === 0) return 0;

  const rows = grid.length;
  const cols = grid[0].length;

  const neighborCounts = Array.from({ length: rows }, () =>
    new Array(cols).fill(0)
  );

  const queue = [];

  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      if (grid[r][c] === "@") {
        const count = countNeighbors(grid, r, c);
        neighborCounts[r][c] = count;
        if (count < 4) {
          queue.push({ r, c });
        }
      }
    }
  }

  let totalRemoved = 0;
  let head = 0;
  while (head < queue.length) {
    const { r, c } = queue[head++];

    if (grid[r][c] === ".") {
      continue;
    }

    grid[r][c] = ".";
    totalRemoved++;

    for (let i = 0; i < 8; i++) {
      const nr = r + DR[i];
      const nc = c + DC[i];
      if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
        if (grid[nr][nc] === "@") {
          neighborCounts[nr][nc]--;
          if (neighborCounts[nr][nc] === 3) {
            queue.push({ r: nr, c: nc });
          }
        }
      }
    }
  }

  return totalRemoved;
}

export function run() {
  const testPath = "../inputs/day04_test.txt";
  const realPath = "../inputs/day04.txt";

  runSolution("Part 1", part1, testPath, realPath, 13);
  runSolution("Part 2", part2, testPath, realPath, 43);
}
