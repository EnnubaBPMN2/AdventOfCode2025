import { runSolution } from "../utils/runner.ts";

interface Point {
  x: number;
  y: number;
}

function parsePoints(input: string): Point[] {
  return input
    .replace(/\r\n/g, "\n")
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l !== "")
    .map((line) => {
      const parts = line.split(",");
      return { x: parseInt(parts[0]), y: parseInt(parts[1]) };
    });
}

function isPointOnSegment(p: Point, s1: Point, s2: Point): boolean {
  if (s1.x === s2.x && s1.x === p.x) {
    return p.y >= Math.min(s1.y, s2.y) && p.y <= Math.max(s1.y, s2.y);
  }
  if (s1.y === s2.y && s1.y === p.y) {
    return p.x >= Math.min(s1.x, s2.x) && p.x <= Math.max(s1.x, s2.x);
  }
  return false;
}

function isInsidePolygon(p: Point, polygon: Point[]): boolean {
  let intersections = 0;
  const n = polygon.length;
  for (let i = 0; i < n; i++) {
    const p1 = polygon[i];
    const p2 = polygon[(i + 1) % n];

    if (p1.y > p.y !== p2.y > p.y) {
      const intersectX =
        ((p2.x - p1.x) * (p.y - p1.y)) / (p2.y - p1.y) + p1.x;
      if (p.x < intersectX) {
        intersections++;
      }
    }
  }
  return intersections % 2 === 1;
}

function isInsideOrOnBoundary(p: Point, polygon: Point[]): boolean {
  for (let i = 0; i < polygon.length; i++) {
    if (isPointOnSegment(p, polygon[i], polygon[(i + 1) % polygon.length])) {
      return true;
    }
  }
  return isInsidePolygon(p, polygon);
}

function direction(p1: Point, p2: Point, p3: Point): number {
  const val = (p3.y - p1.y) * (p2.x - p1.x) - (p2.y - p1.y) * (p3.x - p1.x);
  if (val === 0) return 0;
  return val > 0 ? 1 : -1;
}

function segmentsProperlyIntersect(p1: Point, p2: Point, p3: Point, p4: Point): boolean {
  const d1 = direction(p3, p4, p1);
  const d2 = direction(p3, p4, p2);
  const d3 = direction(p1, p2, p3);
  const d4 = direction(p1, p2, p4);

  return (
    ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
    ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))
  );
}

export function part1(input: string): number {
  const points = parsePoints(input);
  if (points.length < 2) return 0;

  let maxArea = 0;
  for (let i = 0; i < points.length; i++) {
    for (let j = i + 1; j < points.length; j++) {
      const p1 = points[i],
        p2 = points[j];
      const area = (Math.abs(p1.x - p2.x) + 1) * (Math.abs(p1.y - p2.y) + 1);
      if (area > maxArea) maxArea = area;
    }
  }
  return maxArea;
}

export function part2(input: string): number {
  const points = parsePoints(input);
  if (points.length < 2) return 0;

  let maxArea = 0;
  const n = points.length;

  for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
      const p1 = points[i],
        p2 = points[j];
      const minX = Math.min(p1.x, p2.x),
        maxX = Math.max(p1.x, p2.x);
      const minY = Math.min(p1.y, p2.y),
        maxY = Math.max(p1.y, p2.y);

      // Corner checks
      if (
        !isInsideOrOnBoundary({ x: minX, y: minY }, points) ||
        !isInsideOrOnBoundary({ x: minX, y: maxY }, points) ||
        !isInsideOrOnBoundary({ x: maxX, y: minY }, points) ||
        !isInsideOrOnBoundary({ x: maxX, y: maxY }, points)
      ) {
        continue;
      }

      // Interior tile check - none of the boundary points can be inside
      let hasInterior = false;
      for (let k = 0; k < n; k++) {
        const pk = points[k];
        if (pk.x > minX && pk.x < maxX && pk.y > minY && pk.y < maxY) {
          hasInterior = true;
          break;
        }
      }
      if (hasInterior) continue;

      // Boundary crossing check
      let hasCrossing = false;
      const rectCorners = [
        { x: minX, y: minY },
        { x: maxX, y: minY },
        { x: maxX, y: maxY },
        { x: minX, y: maxY },
      ];
      for (let k = 0; k < n; k++) {
        const pk1 = points[k];
        const pk2 = points[(k + 1) % n];

        for (let r = 0; r < 4; r++) {
          if (
            segmentsProperlyIntersect(pk1, pk2, rectCorners[r], rectCorners[(r + 1) % 4])
          ) {
            hasCrossing = true;
            break;
          }
        }
        if (hasCrossing) break;
      }

      if (!hasCrossing) {
        const area = (maxX - minX + 1) * (maxY - minY + 1);
        if (area > maxArea) maxArea = area;
      }
    }
  }

  return maxArea;
}

export function run() {
  const testPath = "../inputs/day09_test.txt";
  const realPath = "../inputs/day09.txt";

  runSolution("Part 1", part1, testPath, realPath, 50);
  runSolution("Part 2", part2, testPath, realPath, 24);
}
