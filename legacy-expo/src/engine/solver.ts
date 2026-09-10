// Solver: verilen değer/operatör dizisi için TÜM olası parantezlemeleri
// (katlama sıralarını) deneyip hangi sonuçların kaç farklı yoldan elde
// edildiğini hesaplar. Bu klasik "farklı parantezlemelerin tüm sonuçları"
// problemiyle aynı algoritma (interval DP / Catalan sayımı).
//
// Kullanım alanları:
//  1) Level üretiminde: hedefe kaç farklı katlama sırası ulaşıyor
//     (solutionCount) — zorluk ayarı için.
//  2) Test/doğrulama: bir level'ın gerçekten çözülebilir olduğunu garanti
//     etmek (aşağıdaki tests/ script'i bunu kullanır).

import { Operator } from '../types';

/** value -> o değere ulaşan farklı parantezleme (katlama sırası) sayısı. */
export type ResultCounts = Map<number, number>;

/**
 * values.length === operators.length + 1 olmalı.
 * Dönen map'teki tüm count'ların toplamı Catalan(n-1)'e eşittir.
 */
export function enumerateAllResults(values: number[], operators: Operator[]): ResultCounts {
  const n = values.length;
  if (n === 0) return new Map();
  if (operators.length !== n - 1) {
    throw new Error('operators.length, values.length - 1 olmalı');
  }

  // memo[lo][hi] = ResultCounts for values[lo..hi] inclusive
  const memo: (ResultCounts | undefined)[][] = Array.from({ length: n }, () =>
    Array.from({ length: n }, () => undefined),
  );

  function solve(lo: number, hi: number): ResultCounts {
    const cached = memo[lo][hi];
    if (cached) return cached;

    if (lo === hi) {
      const m: ResultCounts = new Map([[values[lo], 1]]);
      memo[lo][hi] = m;
      return m;
    }

    const result: ResultCounts = new Map();
    for (let split = lo; split < hi; split += 1) {
      const leftResults = solve(lo, split);
      const rightResults = solve(split + 1, hi);
      const op = operators[split];
      for (const [lv, lCount] of leftResults) {
        for (const [rv, rCount] of rightResults) {
          const combined = op === '+' ? lv + rv : lv * rv;
          const addCount = lCount * rCount;
          result.set(combined, (result.get(combined) ?? 0) + addCount);
        }
      }
    }
    memo[lo][hi] = result;
    return result;
  }

  return solve(0, n - 1);
}

export function totalArrangementsFor(n: number): number {
  // Catalan(n-1): n hücreyi tek hücreye indirgeyen farklı parantezleme sayısı
  if (n <= 1) return 1;
  const catalan: number[] = [1];
  for (let i = 1; i < n; i += 1) {
    let sum = 0;
    for (let j = 0; j < i; j += 1) {
      sum += catalan[j] * catalan[i - 1 - j];
    }
    catalan.push(sum);
  }
  return catalan[n - 1];
}

export function solutionCountFor(values: number[], operators: Operator[], target: number): number {
  const results = enumerateAllResults(values, operators);
  return results.get(target) ?? 0;
}
