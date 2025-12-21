import { runSolution } from "../utils/runner.js";

function normalize(points) {
  let minR = Infinity,
    minC = Infinity;
  for (const p of points) {
    if (p.r < minR) minR = p.r;
    if (p.c < minC) minC = p.c;
  }
  const normalized = points.map((p) => ({ r: p.r - minR, c: p.c - minC }));
  let maxR = 0,
    maxC = 0;
  for (const p of normalized) {
    if (p.r > maxR) maxR = p.r;
    if (p.c > maxC) maxC = p.c;
  }
  return {
    points: normalized,
    height: maxR + 1,
    width: maxC + 1,
    area: points.length,
  };
}

function rotate(points) {
  return points.map((p) => ({ r: p.c, c: -p.r }));
}

function flip(points) {
  return points.map((p) => ({ r: p.r, c: -p.c }));
}

function shapeToString(s) {
  const grid = Array.from({ length: s.height }, () =>
    new Array(s.width).fill(false)
  );
  for (const p of s.points) grid[p.r][p.c] = true;
  return grid.map((row) => row.map((b) => (b ? "#" : ".")).join("")).join("\n");
}

function getOrientations(s) {
  const unique = new Map();
  let current = s.points;
  for (let r = 0; r < 4; r++) {
    const normed = normalize(current);
    unique.set(shapeToString(normed), normed);

    const flipped = flip(current);
    const normedFlipped = normalize(flipped);
    unique.set(shapeToString(normedFlipped), normedFlipped);

    current = rotate(current);
  }
  return Array.from(unique.values());
}

function parseRegions(input) {
  const lines = input.replace(/\r\n/g, "\n").split("\n");
  const shapesRaw = [];
  const regions = [];

  let i = 0;
  while (i < lines.length) {
    const line = lines[i].trim();
    if (line === "") {
      i++;
      continue;
    }

    if (line.includes("x") && line.includes(":")) {
      const parts = line.split(":");
      const dimParts = parts[0].trim().split("x");
      const w = parseInt(dimParts[0]);
      const h = parseInt(dimParts[1]);
      const countParts = parts[1].trim().split(/\s+/);
      const counts = countParts.map(Number);
      regions.push({ width: w, height: h, counts });
      i++;
    } else if (line.includes(":")) {
      i++;
      const shapeLines = [];
      while (i < lines.length && lines[i].trim() !== "" && !lines[i].includes(":")) {
        shapeLines.push(lines[i]);
        i++;
      }
      shapesRaw.push(shapeLines);
    } else {
      i++;
    }
  }

  const shapes = shapesRaw.map((raw) => {
    const points = [];
    raw.forEach((line, r) => {
      line.split("").forEach((ch, c) => {
        if (ch === "#") points.push({ r, c });
      });
    });
    return normalize(points);
  });

  return { shapes, regions };
}

function canPlace(grid, w, h, s, r, c) {
  if (r + s.height > h || c + s.width > w) return false;
  for (const p of s.points) {
    if (grid[(r + p.r) * w + (c + p.c)]) return false;
  }
  return true;
}

function place(grid, w, s, r, c, val) {
  for (const p of s.points) {
    grid[(r + p.r) * w + (c + p.c)] = val;
  }
}

function solve(
  grid,
  w,
  h,
  counts,
  orientations
) {
  let shapeIdx = -1;
  for (let i = 0; i < counts.length; i++) {
    if (counts[i] > 0) {
      shapeIdx = i;
      break;
    }
  }

  if (shapeIdx === -1) return true;

  for (const orient of orientations[shapeIdx]) {
    for (let r = 0; r <= h - orient.height; r++) {
      for (let c = 0; c <= w - orient.width; c++) {
        if (canPlace(grid, w, h, orient, r, c)) {
          place(grid, w, orient, r, c, true);
          counts[shapeIdx]--;
          if (solve(grid, w, h, counts, orientations)) return true;
          counts[shapeIdx]++;
          place(grid, w, orient, r, c, false);
        }
      }
    }
  }

  return false;
}

export function part1(input) {
  const { shapes, regions } = parseRegions(input);
  const orientations = shapes.map((s) => getOrientations(s));

  let totalCount = 0;
  for (const reg of regions) {
    let requiredArea = 0;
    for (let i = 0; i < reg.counts.length; i++) {
      requiredArea += reg.counts[i] * shapes[i].area;
    }
    if (requiredArea > reg.width * reg.height) continue;

    const grid = new Array(reg.width * reg.height).fill(false);
    const counts = [...reg.counts];

    if (solve(grid, reg.width, reg.height, counts, orientations)) {
      totalCount++;
    }
  }
  return totalCount;
}

export function run() {
  const testPath = "../inputs/day12_test.txt";
  const realPath = "../inputs/day12.txt";

  runSolution("Part 1", part1, testPath, realPath, 2);
  console.log("\n🎄 Part 2 automatically completed! Both stars earned! 🎄");
}
