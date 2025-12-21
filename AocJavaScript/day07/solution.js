import { runSolution } from "../utils/runner.js";

function parseGrid(input) {
  const lines = input.replace(/\r\n/g, "\n").split("\n");
  const grid = [];
  let sr = -1,
    sc = -1;

  for (let r = 0; r < lines.length; r++) {
    const line = lines[r].trim();
    if (line === "") continue;
    if (sc === -1) {
      const idx = line.indexOf("S");
      if (idx !== -1) {
        sr = grid.length;
        sc = idx;
      }
    }
    grid.push(line.split(""));
  }
  return { grid, sr, sc };
}

export function part1(input) {
  const { grid, sr, sc } = parseGrid(input);
  if (sr === -1) return 0;

  const height = grid.length;
  const width = grid[0].length;
  let active = new Uint8Array(width);
  active[sc] = 1;

  let splitCount = 0;

  for (let r = sr + 1; r < height; r++) {
    const nextActive = new Uint8Array(width);
    for (let c = 0; c < width; c++) {
      if (active[c] === 0) continue;

      const cell = grid[r][c];
      if (cell === "^") {
        splitCount++;
        if (c > 0) nextActive[c - 1] = 1;
        if (c + 1 < width) nextActive[c + 1] = 1;
      } else {
        nextActive[c] = 1;
      }
    }
    active = nextActive;
  }

  return splitCount;
}

export function part2(input) {
  const { grid, sr, sc } = parseGrid(input);
  if (sr === -1) return 0;

  const height = grid.length;
  const width = grid[0].length;
  let paths = new BigInt64Array(width);
  paths[sc] = 1n;

  for (let r = sr + 1; r < height; r++) {
    const nextPaths = new BigInt64Array(width);
    for (let c = 0; c < width; c++) {
      const count = paths[c];
      if (count === 0n) continue;

      const cell = grid[r][c];
      if (cell === "^") {
        if (c > 0) nextPaths[c - 1] += count;
        if (c + 1 < width) nextPaths[c + 1] += count;
      } else {
        nextPaths[c] += count;
      }
    }
    paths = nextPaths;
  }

  let totalPaths = 0n;
  for (let i = 0; i < paths.length; i++) {
    totalPaths += paths[i];
  }
  return Number(totalPaths);
}

export function run() {
  const testPath = "../inputs/day07_test.txt";
  const realPath = "../inputs/day07.txt";

  runSolution("Part 1", part1, testPath, realPath, 21);
  runSolution("Part 2", part2, testPath, realPath, 40);
}
