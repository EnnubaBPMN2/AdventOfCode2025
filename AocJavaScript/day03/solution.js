import { runSolution } from "../utils/runner.js";

function getLargestSubsequence(s, k) {
  if (s.length < k) {
    return 0;
  }

  const stack = [];
  const n = s.length;

  for (let i = 0; i < n; i++) {
    const digit = s[i];
    const remaining = n - 1 - i;

    // While stack is not empty, current digit is larger than top of stack,
    // and we have enough remaining digits to still reach length k
    while (
      stack.length > 0 &&
      digit > stack[stack.length - 1] &&
      stack.length + remaining >= k
    ) {
      stack.pop();
    }

    if (stack.length < k) {
      stack.push(digit);
    }
  }

  // Construct result
  let result = 0;
  for (const digit of stack) {
    result = result * 10 + (digit.charCodeAt(0) - "0".charCodeAt(0));
  }
  return result;
}

export function part1(input) {
  const lines = input.trim().split("\n");
  let total = 0;

  for (let line of lines) {
    line = line.trim();
    if (line === "") continue;
    total += getLargestSubsequence(line, 2);
  }

  return total;
}

export function part2(input) {
  const lines = input.trim().split("\n");
  let total = 0;

  for (let line of lines) {
    line = line.trim();
    if (line === "") continue;
    total += getLargestSubsequence(line, 12);
  }

  return total;
}

export function run() {
  const testPath = "../inputs/day03_test.txt";
  const realPath = "../inputs/day03.txt";

  runSolution("Part 1", part1, testPath, realPath, 357);
  runSolution("Part 2", part2, testPath, realPath, 3121910778619);
}
