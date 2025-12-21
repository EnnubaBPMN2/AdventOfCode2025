import { run as runDay01 } from "./day01/solution.js";
import { run as runDay02 } from "./day02/solution.js";
import { run as runDay03 } from "./day03/solution.js";
import { run as runDay04 } from "./day04/solution.js";
import { run as runDay05 } from "./day05/solution.js";
import { run as runDay06 } from "./day06/solution.js";
import { run as runDay07 } from "./day07/solution.js";
import { run as runDay08 } from "./day08/solution.js";
import { run as runDay09 } from "./day09/solution.js";
import { run as runDay10 } from "./day10/solution.js";
import { run as runDay11 } from "./day11/solution.js";
import { run as runDay12 } from "./day12/solution.js";
import * as readline from "readline/promises";

const days = {
  1: runDay01,
  2: runDay02,
  3: runDay03,
  4: runDay04,
  5: runDay05,
  6: runDay06,
  7: runDay07,
  8: runDay08,
  9: runDay09,
  10: runDay10,
  11: runDay11,
  12: runDay12,
};

async function main() {
  console.log("================================================");
  console.log("🎄 Advent of Code 2025 - JavaScript Solutions 🎄");
  console.log("================================================");

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  while (true) {
    const input = await rl.question("\nEnter day number (1-12) or 0 to exit: ");
    const day = parseInt(input);

    if (day === 0) {
      console.log("\n🎄 Happy Coding!");
      break;
    }

    if (days[day]) {
      console.log(`\n📅 Day ${day.toString().padStart(2, "0")}`);
      days[day]();
    } else {
      console.log(`\n❌ Day ${day} not implemented yet.`);
    }
  }

  rl.close();
  process.exit(0);
}

main();
