import { runSolution } from "../utils/runner.ts";

class Graph {
  adj: number[][];
  nodeToID: Map<string, number>;
  idToNode: string[];

  constructor(input: string) {
    const lines = input.replace(/\r\n/g, "\n").split("\n");
    const rawAdj = new Map<string, string[]>();
    const nodes = new Set<string>();

    for (let line of lines) {
      line = line.trim();
      if (line === "") continue;
      const parts = line.split(":");
      if (parts.length !== 2) continue;
      const u = parts[0].trim();
      nodes.add(u);
      const targets = parts[1].trim().split(/\s+/);
      for (const v of targets) {
        const vTrim = v.trim();
        if (vTrim === "") continue;
        nodes.add(vTrim);
        if (!rawAdj.has(u)) rawAdj.set(u, []);
        rawAdj.get(u)!.push(vTrim);
      }
    }

    this.idToNode = Array.from(nodes);
    this.nodeToID = new Map();
    this.idToNode.forEach((n, i) => this.nodeToID.set(n, i));

    this.adj = Array.from({ length: this.idToNode.length }, () => []);
    for (const [u, vList] of rawAdj) {
      const uID = this.nodeToID.get(u)!;
      for (const v of vList) {
        this.adj[uID].push(this.nodeToID.get(v)!);
      }
    }
  }
}

export function part1(input: string): number {
  const g = new Graph(input);
  const startID = g.nodeToID.get("you");
  const endID = g.nodeToID.get("out");
  if (startID === undefined || endID === undefined) return 0;

  const memo = new BigInt64Array(g.idToNode.length).fill(-1n);

  function dfs(u: number): bigint {
    if (u === endID) return 1n;
    if (memo[u] !== -1n) return memo[u];

    let count = 0n;
    for (const v of g.adj[u]) {
      count += dfs(v);
    }
    memo[u] = count;
    return count;
  }

  return Number(dfs(startID));
}

export function part2(input: string): number {
  const g = new Graph(input);
  const startID = g.nodeToID.get("svr");
  const endID = g.nodeToID.get("out");
  const dacID = g.nodeToID.get("dac");
  const fftID = g.nodeToID.get("fft");

  if (startID === undefined || endID === undefined) return 0;

  // Memoization table: node index -> mask (0-3) -> count
  const memoSize = g.idToNode.length;
  const memo = new BigInt64Array(memoSize * 4).fill(-1n);

  function dfs(u: number, mask: number): bigint {
    let newMask = mask;
    if (dacID !== undefined && u === dacID) newMask |= 1;
    if (fftID !== undefined && u === fftID) newMask |= 2;

    if (u === endID) {
      // Check if required nodes were visited based on their existence in graph
      const needsDac = dacID !== undefined;
      const needsFft = fftID !== undefined;
      if (needsDac && (newMask & 1) === 0) return 0n;
      if (needsFft && (newMask & 2) === 0) return 0n;
      return 1n;
    }

    const memoIdx = u * 4 + mask;
    if (memo[memoIdx] !== -1n) return memo[memoIdx];

    let count = 0n;
    for (const v of g.adj[u]) {
      count += dfs(v, newMask);
    }
    memo[memoIdx] = count;
    return count;
  }

  return Number(dfs(startID, 0));
}

export function run() {
  const testPath = "../inputs/day11_test.txt";
  const testPath2 = "../inputs/day11_test_part2.txt";
  const realPath = "../inputs/day11.txt";

  runSolution("Part 1", part1, testPath, realPath, 5);
  runSolution("Part 2", part2, testPath2, realPath, 2);
}
