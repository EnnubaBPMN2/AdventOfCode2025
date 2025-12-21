import { readFileSync, existsSync } from "fs";

export function runSolution<T>(
  name: string,
  solve: (input: string) => T,
  testPath: string,
  realPath: string,
  expectedTestResult?: T
) {
  console.log(`\n=== ${name} ===`);

  // Running Test
  if (existsSync(testPath)) {
    const testInput = readFileSync(testPath, "utf-8");
    const testStart = Bun.nanoseconds();
    const testResult = solve(testInput);
    const testEnd = Bun.nanoseconds();
    const testDuration = (testEnd - testStart) / 1_000_000;

    if (expectedTestResult !== undefined) {
      if (testResult === expectedTestResult) {
        console.log(`✓ Test PASSED: ${testResult} in ${testDuration.toFixed(4)}ms`);
      } else {
        console.log(`✗ Test FAILED: ${testResult} (expected ${expectedTestResult}) in ${testDuration.toFixed(4)}ms`);
      }
    } else {
      console.log(`→ Test Result: ${testResult} in ${testDuration.toFixed(4)}ms`);
    }
  } else {
    console.log(`! Test input not found at ${testPath}`);
  }

  // Running Real
  if (existsSync(realPath)) {
    const realInput = readFileSync(realPath, "utf-8");
    const realStart = Bun.nanoseconds();
    const realResult = solve(realInput);
    const realEnd = Bun.nanoseconds();
    const realDuration = (realEnd - realStart) / 1_000_000;

    console.log(`→ Real Answer: ${realResult} in ${realDuration.toFixed(4)}ms`);
  } else {
    console.log(`! Real input not found at ${realPath}`);
  }
}

export function formatDuration(ns: number): string {
  if (ns < 1000) return `${ns.toFixed(2)}ns`;
  if (ns < 1000000) return `${(ns / 1000).toFixed(2)}µs`;
  return `${(ns / 1000000).toFixed(2)}ms`;
}
