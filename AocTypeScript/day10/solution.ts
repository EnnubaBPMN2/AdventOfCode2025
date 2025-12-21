import { runSolution } from "../utils/runner.ts";

interface Machine {
  indicator: boolean[];
  buttons: boolean[][];
  jolts: bigint[];
}

function parseMachine(line: string): Machine {
  const indicatorMatch = line.match(/\[([.#]+)\]/);
  const indicator = indicatorMatch ? indicatorMatch[1].split("").map((c) => c === "#") : [];

  const buttonMatches = line.matchAll(/\(([\d,]+)\)/g);
  const buttons: boolean[][] = [];
  for (const m of buttonMatches) {
    const indices = m[1].split(",").map(Number);
    const button = new Array(indicator.length).fill(false);
    for (const idx of indices) {
      if (idx < button.length) button[idx] = true;
    }
    buttons.push(button);
  }

  const joltsMatch = line.match(/\{([\d,]+)\}/);
  const jolts = joltsMatch ? joltsMatch[1].split(",").map((s) => BigInt(s)) : [];

  return { indicator, buttons, jolts };
}

function solveGF2(target: boolean[], buttons: boolean[][]): number | null {
  const rows = target.length;
  const cols = buttons.length;
  const matrix: boolean[][] = Array.from({ length: rows }, (_, i) => {
    const r = new Array(cols + 1).fill(false);
    for (let j = 0; j < cols; j++) {
      r[j] = buttons[j][i];
    }
    r[cols] = target[i];
    return r;
  });

  const pivot = new Int32Array(rows).fill(-1);
  let r = 0,
    c = 0;
  while (r < rows && c < cols) {
    let pivotRow = -1;
    for (let i = r; i < rows; i++) {
      if (matrix[i][c]) {
        pivotRow = i;
        break;
      }
    }

    if (pivotRow === -1) {
      c++;
      continue;
    }

    [matrix[r], matrix[pivotRow]] = [matrix[pivotRow], matrix[r]];
    pivot[r] = c;

    for (let i = 0; i < rows; i++) {
      if (i !== r && matrix[i][c]) {
        for (let j = c; j <= cols; j++) {
          matrix[i][j] = matrix[i][j] !== matrix[r][j];
        }
      }
    }
    r++;
    c++;
  }

  for (let i = 0; i < rows; i++) {
    let allZero = true;
    for (let j = 0; j < cols; j++) {
      if (matrix[i][j]) {
        allZero = false;
        break;
      }
    }
    if (allZero && matrix[i][cols]) return null;
  }

  const isPivot = new Uint8Array(cols);
  for (const p of pivot) {
    if (p !== -1) isPivot[p] = 1;
  }

  const freeVars: number[] = [];
  for (let j = 0; j < cols; j++) {
    if (isPivot[j] === 0) freeVars.push(j);
  }

  let minPresses = Infinity;
  const numFree = Math.min(freeVars.length, 15);
  const limit = 1 << numFree;

  for (let mask = 0; mask < limit; mask++) {
    const sol = new Uint8Array(cols);
    for (let i = 0; i < numFree; i++) {
      if ((mask >> i) & 1) sol[freeVars[i]] = 1;
    }

    for (let i = rows - 1; i >= 0; i--) {
      const pCol = pivot[i];
      if (pCol === -1) continue;
      let val = matrix[i][cols];
      for (let j = pCol + 1; j < cols; j++) {
        if (matrix[i][j] && sol[j]) val = !val;
      }
      sol[pCol] = val ? 1 : 0;
    }

    let count = 0;
    for (const v of sol) if (v === 1) count++;
    if (count < minPresses) minPresses = count;
  }

  return minPresses === Infinity ? null : minPresses;
}

function solveILP(target: bigint[], buttons: boolean[][]): bigint {
  const rows = target.length;
  const cols = buttons.length;
  const matrix: number[][] = Array.from({ length: rows }, (_, i) => {
    const r = new Array(cols + 1).fill(0);
    for (let j = 0; j < cols; j++) {
      if (buttons[j][i]) r[j] = 1;
    }
    r[cols] = Number(target[i]);
    return r;
  });

  const pivot = new Int32Array(rows).fill(-1);
  const eps = 1e-9;
  let r = 0,
    c = 0;
  while (r < rows && c < cols) {
    let pivotRow = -1;
    for (let i = r; i < rows; i++) {
      if (Math.abs(matrix[i][c]) > eps) {
        pivotRow = i;
        break;
      }
    }

    if (pivotRow === -1) {
      c++;
      continue;
    }

    [matrix[r], matrix[pivotRow]] = [matrix[pivotRow], matrix[r]];
    pivot[r] = c;

    const divisor = matrix[r][c];
    for (let j = c; j <= cols; j++) matrix[r][j] /= divisor;

    for (let i = 0; i < rows; i++) {
      if (i !== r && Math.abs(matrix[i][c]) > eps) {
        const factor = matrix[i][c];
        for (let j = c; j <= cols; j++) matrix[i][j] -= factor * matrix[r][j];
      }
    }
    r++;
    c++;
  }

  const isPivot = new Uint8Array(cols);
  for (const p of pivot) if (p !== -1) isPivot[p] = 1;

  const freeVars: number[] = [];
  for (let j = 0; j < cols; j++) if (isPivot[j] === 0) freeVars.push(j);

  let maxTarget = 0;
  for (const t of target) if (Number(t) > maxTarget) maxTarget = Number(t);

  let minPresses = BigInt(Number.MAX_SAFE_INTEGER);

  function search(idx: number, currentSol: bigint[], currentSum: bigint) {
    if (idx === freeVars.length) {
      const testSol = [...currentSol];
      let valid = true;
      let sum = currentSum;

      for (let i = rows - 1; i >= 0; i--) {
        const pCol = pivot[i];
        if (pCol === -1) continue;

        let val = matrix[i][cols];
        for (let j = pCol + 1; j < cols; j++) {
          if (Math.abs(matrix[i][j]) > eps) {
            val -= matrix[i][j] * Number(testSol[j]);
          }
        }

        if (val < -eps || Math.abs(val - Math.round(val)) > eps) {
          valid = false;
          break;
        }
        const v = BigInt(Math.round(val));
        if (v < 0n) {
          valid = false;
          break;
        }
        testSol[pCol] = v;
        sum += v;
      }

      if (valid && sum < minPresses) {
        minPresses = sum;
      }
      return;
    }

    const vIdx = freeVars[idx];
    for (let val = 0n; val <= BigInt(maxTarget); val++) {
      if (currentSum + val >= minPresses) break;
      currentSol[vIdx] = val;
      search(idx + 1, currentSol, currentSum + val);
    }
    currentSol[vIdx] = 0n;
  }

  if (freeVars.length === 0) {
    let sum = 0n;
    let valid = true;
    for (let i = 0; i < rows; i++) {
      const pCol = pivot[i];
      if (pCol === -1) {
        if (Math.abs(matrix[i][cols]) > eps) {
          valid = false;
          break;
        }
        continue;
      }
      const val = matrix[i][cols];
      if (val < -eps || Math.abs(val - Math.round(val)) > eps) {
        valid = false;
        break;
      }
      const v = BigInt(Math.round(val));
      if (v < 0n) {
        valid = false;
        break;
      }
      sum += v;
    }
    return valid ? sum : 0n;
  }

  const currentSol = new Array(cols).fill(0n);
  search(0, currentSol, 0n);

  return minPresses === BigInt(Number.MAX_SAFE_INTEGER) ? 0n : minPresses;
}

export function part1(input: string): number {
  const lines = input.trim().split("\n");
  let total = 0;
  for (const line of lines) {
    if (line.trim() === "") continue;
    const m = parseMachine(line);
    const res = solveGF2(m.indicator, m.buttons);
    if (res !== null) total += res;
  }
  return total;
}

export function part2(input: string): number {
  const lines = input.trim().split("\n");
  let total = 0n;
  for (const line of lines) {
    if (line.trim() === "") continue;
    const m = parseMachine(line);
    const res = solveILP(m.jolts, m.buttons);
    total += res;
  }
  return Number(total);
}

export function run() {
  const testPath = "../inputs/day10_test.txt";
  const realPath = "../inputs/day10.txt";

  runSolution("Part 1", part1, testPath, realPath, 7);
  runSolution("Part 2", part2, testPath, realPath, 33);
}
