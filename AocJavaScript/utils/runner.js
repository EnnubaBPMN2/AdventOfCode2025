import { readFileSync, existsSync } from "fs";

export function runSolution(
  name,
  solve,
  testPath,
  realPath,
  expectedTestResult
) {
  console.log(`\n=== ${name} ===`);

  // Running Test
  if (existsSync(testPath)) {
    const testInput = readFileSync(testPath, "utf-8");
    const testStart = performance.now();
    const testResult = solve(testInput);
    const testEnd = performance.now();
    const testDuration = testEnd - testStart;

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
    const realStart = performance.now();
    const realResult = solve(realInput);
    const realEnd = performance.now();
    const realDuration = realEnd - realStart;

    console.log(`→ Real Answer: ${realResult} in ${realDuration.toFixed(4)}ms`);
  } else {
    console.log(`! Real input not found at ${realPath}`);
  }
}

export function formatDuration(ns) {
  if (ns < 1000) return `${ns.toFixed(2)}ns`;
  if (ns < 1000000) return `${(ns / 1000).toFixed(2)}µs`;
  return `${(ns / 1000000).toFixed(2)}ms`;
}
