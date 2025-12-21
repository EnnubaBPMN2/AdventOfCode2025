import { runSolution } from "../utils/runner.ts";

class DSU {
  parent: Int32Array;
  size: Int32Array;
  components: number;

  constructor(n: number) {
    this.parent = new Int32Array(n);
    this.size = new Int32Array(n).fill(1);
    this.components = n;
    for (let i = 0; i < n; i++) this.parent[i] = i;
  }

  find(i: number): number {
    if (this.parent[i] === i) return i;
    this.parent[i] = this.find(this.parent[i]);
    return this.parent[i];
  }

  union(i: number, j: number): boolean {
    let rootI = this.find(i);
    let rootJ = this.find(j);
    if (rootI !== rootJ) {
      if (this.size[rootI] < this.size[rootJ]) {
        [rootI, rootJ] = [rootJ, rootI];
      }
      this.parent[rootJ] = rootI;
      this.size[rootI] += this.size[rootJ];
      this.components--;
      return true;
    }
    return false;
  }
}

interface Point {
  x: bigint;
  y: bigint;
  z: bigint;
}

interface Edge {
  distSq: bigint;
  i: number;
  j: number;
}

function parsePoints(input: string): Point[] {
  return input
    .replace(/\r\n/g, "\n")
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l !== "")
    .map((line) => {
      const p = line.split(",").map((s) => BigInt(s.trim()));
      return { x: p[0], y: p[1], z: p[2] };
    });
}

function getSortedEdges(points: Point[]): Edge[] {
  const n = points.length;
  const edges: Edge[] = [];
  for (let i = 0; i < n; i++) {
    for (let j = i + 1; j < n; j++) {
      const dx = points[i].x - points[j].x;
      const dy = points[i].y - points[j].y;
      const dz = points[i].z - points[j].z;
      const distSq = dx * dx + dy * dy + dz * dz;
      edges.push({ distSq, i, j });
    }
  }

  edges.sort((a, b) => {
    if (a.distSq === b.distSq) {
      if (a.i === b.i) return a.j - b.j;
      return a.i - b.i;
    }
    return a.distSq < b.distSq ? -1 : 1;
  });
  return edges;
}

export function part1(input: string): number {
  const points = parsePoints(input);
  if (points.length === 0) return 0;
  const edges = getSortedEdges(points);
  const dsu = new DSU(points.length);

  const limit = points.length === 20 ? 10 : 1000;

  for (let i = 0; i < limit && i < edges.length; i++) {
    dsu.union(edges[i].i, edges[i].j);
  }

  const circuitSizeMap = new Map<number, bigint>();
  for (let i = 0; i < points.length; i++) {
    const root = dsu.find(i);
    circuitSizeMap.set(root, (circuitSizeMap.get(root) || 0n) + 1n);
  }

  const sizes = Array.from(circuitSizeMap.values()).sort((a, b) => (a > b ? -1 : 1));

  let res = 1n;
  for (let i = 0; i < 3 && i < sizes.length; i++) {
    res *= sizes[i];
  }
  return Number(res);
}

export function part2(input: string): number {
  const points = parsePoints(input);
  if (points.length === 0) return 0;
  const edges = getSortedEdges(points);
  const dsu = new DSU(points.length);

  let lastI = 0,
    lastJ = 0;
  for (const edge of edges) {
    if (dsu.union(edge.i, edge.j)) {
      lastI = edge.i;
      lastJ = edge.j;
      if (dsu.components === 1) break;
    }
  }

  return Number(points[lastI].x * points[lastJ].x);
}

export function run() {
  const testPath = "../inputs/day08_test.txt";
  const realPath = "../inputs/day08.txt";

  runSolution("Part 1", part1, testPath, realPath, 40);
  runSolution("Part 2", part2, testPath, realPath, 25272);
}
