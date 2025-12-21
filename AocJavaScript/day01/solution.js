import { runSolution } from "../utils/runner.js";

export function part1(input) {
  const rotations = input.trim().split(/\s+/);
  let position = 50;
  let zeroCount = 0;

  for (const rotation of rotations) {
    if (rotation.length < 2) continue;

    const direction = rotation[0];
    const distance = parseInt(rotation.substring(1));

    if (direction === "L") {
      position = (position - distance) % 100;
      if (position < 0) position += 100;
    } else if (direction === "R") {
      position = (position + distance) % 100;
    }

    if (position === 0) zeroCount++;
  }

  return zeroCount;
}

export function part2(input) {
  const rotations = input.trim().split(/\s+/);
  let position = 50;
  let zeroCount = 0;

  for (const rotation of rotations) {
    if (rotation.length < 2) continue;

    const direction = rotation[0];
    const distance = parseInt(rotation.substring(1));

    if (direction === "R") {
      // Moving right: count multiples of 100 in range (position, position + distance]
      zeroCount += Math.floor((position + distance) / 100);
      position = (position + distance) % 100;
    } else if (direction === "L") {
      // Moving left: count multiples of 100 in range [position - distance, position)
      const startFloor = position - 1 < 0 ? -1 : 0;
      const endFloor = Math.floor((position - distance - 1) / 100);

      zeroCount += startFloor - endFloor;

      position = (position - distance) % 100;
      if (position < 0) position += 100;
    }
  }

  return zeroCount;
}

export function run() {
  const testPath = "../inputs/day01_test.txt";
  const realPath = "../inputs/day01.txt";

  runSolution("Part 1", part1, testPath, realPath, 3);
  runSolution("Part 2", part2, testPath, realPath, 6);
}
