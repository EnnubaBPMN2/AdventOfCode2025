import { runSolution } from "../utils/runner.ts";

interface Range {
  start: number;
  end: number;
}

function parseAndMergeRanges(input: string): Range[] {
  const lines = input.trim().split("\n");
  const ranges: Range[] = [];

  for (let line of lines) {
    line = line.trim();
    if (line === "") continue;
    const parts = line.split("-").map(Number);
    if (parts.length === 2) {
      ranges.push({ start: parts[0], end: parts[1] });
    }
  }

  if (ranges.length === 0) return [];

  // Sort by start
  ranges.sort((a, b) => a.start - b.start);

  // Merge overlapping or adjacent ranges
  const merged: Range[] = [];
  let curr = ranges[0];
  for (let i = 1; i < ranges.length; i++) {
    if (ranges[i].start <= curr.end + 1) {
      curr.end = Math.max(curr.end, ranges[i].end);
    } else {
      merged.push(curr);
      curr = ranges[i];
    }
  }
  merged.push(curr);

  return merged;
}

function isFresh(id: number, merged: Range[]): boolean {
  let low = 0;
  let high = merged.length - 1;
  while (low <= high) {
    const mid = (low + high) >> 1;
    if (merged[mid].start <= id && id <= merged[mid].end) {
      return true;
    } else if (merged[mid].end < id) {
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }
  return false;
}

export function part1(input: string): number {
  const sections = input.replace(/\r\n/g, "\n").trim().split("\n\n");
  if (sections.length < 2) return 0;

  const mergedRanges = parseAndMergeRanges(sections[0]);
  let freshCount = 0;
  const idsLines = sections[1].split("\n");
  for (let line of idsLines) {
    line = line.trim();
    if (line === "") continue;
    const id = parseInt(line);
    if (isFresh(id, mergedRanges)) {
      freshCount++;
    }
  }

  return freshCount;
}

export function part2(input: string): number {
  const sections = input.replace(/\r\n/g, "\n").trim().split("\n\n");
  if (sections.length === 0) return 0;

  const mergedRanges = parseAndMergeRanges(sections[0]);
  let totalFresh = 0;
  for (const r of mergedRanges) {
    totalFresh += r.end - r.start + 1;
  }

  return totalFresh;
}

export function run() {
  const testPath = "../inputs/day05_test.txt";
  const realPath = "../inputs/day05.txt";

  runSolution("Part 1", part1, testPath, realPath, 3);
  runSolution("Part 2", part2, testPath, realPath, 14);
}
