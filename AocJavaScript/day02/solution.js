import { runSolution } from "../utils/runner.js";

function parseAndMergeRanges(input) {
  const rawSegments = input.trim().split(",");
  const ranges = [];

  for (const seg of rawSegments) {
    const parts = seg.trim().split("-");
    if (parts.length === 2) {
      ranges.push({
        min: parseInt(parts[0]),
        max: parseInt(parts[1]),
      });
    }
  }

  if (ranges.length === 0) return [];

  // Sort by min
  ranges.sort((a, b) => a.min - b.min);

  const merged = [];
  let curr = ranges[0];

  for (let i = 1; i < ranges.length; i++) {
    if (ranges[i].min <= curr.max) {
      curr.max = Math.max(curr.max, ranges[i].max);
    } else {
      merged.push(curr);
      curr = ranges[i];
    }
  }
  merged.push(curr);

  return merged;
}

function isInRanges(val, ranges) {
  // Binary search for efficiency
  let low = 0;
  let high = ranges.length - 1;
  while (low <= high) {
    const mid = (low + high) >> 1;
    if (ranges[mid].min <= val && val <= ranges[mid].max) {
      return true;
    } else if (ranges[mid].max < val) {
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }
  return false;
}

export function part1(input) {
  const ranges = parseAndMergeRanges(input);
  let sum = 0;

  for (let halfLen = 1; halfLen <= 5; halfLen++) {
    const start = Math.pow(10, halfLen - 1);
    const end = Math.pow(10, halfLen) - 1;

    for (let n = start; n <= end; n++) {
      const s = n.toString();
      const pattern = parseInt(s + s);

      if (isInRanges(pattern, ranges)) {
        sum += pattern;
      }
    }
  }

  return sum;
}

export function part2(input) {
  const ranges = parseAndMergeRanges(input);
  const invalidIDs = new Set();

  for (let patternLen = 1; patternLen <= 5; patternLen++) {
    const start = Math.pow(10, patternLen - 1);
    const end = Math.pow(10, patternLen) - 1;

    for (let n = start; n <= end; n++) {
      const s = n.toString();
      let current = s;
      // Repeat at least twice, up to max 10 digits
      for (let k = 2; k <= 10 / patternLen; k++) {
        current += s;
        const pattern = parseInt(current);
        if (isInRanges(pattern, ranges)) {
          invalidIDs.add(pattern);
        }
      }
    }
  }

  let sum = 0;
  for (const id of invalidIDs) {
    sum += id;
  }

  return sum;
}

export function run() {
  const testPath = "../inputs/day02_test.txt";
  const realPath = "../inputs/day02.txt";

  runSolution("Part 1", part1, testPath, realPath, 1227775554);
  runSolution("Part 2", part2, testPath, realPath, 4174379265);
}
