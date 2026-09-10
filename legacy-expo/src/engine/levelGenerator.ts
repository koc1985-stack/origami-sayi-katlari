// Level üretici: rastgele bir değer/operatör dizisi kurar, solver ile
// hangi sonuçların ne kadar "nadir" (kaç farklı katlama sırasıyla
// ulaşılabilir) olduğunu bulur ve zorluk hedefine uyan bir level döndürür.
//
// v1'de bu üretici asıl olarak curated level setini (src/data/levels.ts)
// üretmek/doğrulamak için kullanıldı — bkz. scripts/generateLevels.ts.
// İleride "sonsuz level" moduna geçilirse runtime'da da çağrılabilir.

import { LevelDef, Operator } from '../types';
import { enumerateAllResults, totalArrangementsFor } from './solver';

export interface GeneratorOptions {
  cellCount: number; // n
  minValue: number;
  maxValue: number;
  /** Kullanılabilecek operatörler; her crease için rastgele seçilir. */
  allowedOperators: Operator[];
  /**
   * Zorluk hedefi: hedefe ulaşan farklı yol sayısı [minSolutions, maxSolutions]
   * aralığında olmalı. Örn. hard için [1,1], easy için [3, totalArrangements].
   */
  minSolutions: number;
  maxSolutions: number;
  rng?: () => number; // test edilebilirlik için enjekte edilebilir (varsayılan Math.random)
  maxAttempts?: number;
}

function randInt(rng: () => number, min: number, max: number): number {
  return Math.floor(rng() * (max - min + 1)) + min;
}

export function tryGenerateLevel(idPrefix: string, opts: GeneratorOptions): LevelDef | null {
  const rng = opts.rng ?? Math.random;
  const maxAttempts = opts.maxAttempts ?? 500;

  for (let attempt = 0; attempt < maxAttempts; attempt += 1) {
    const values: number[] = Array.from({ length: opts.cellCount }, () =>
      randInt(rng, opts.minValue, opts.maxValue),
    );
    const operators: Operator[] = Array.from(
      { length: opts.cellCount - 1 },
      () => opts.allowedOperators[randInt(rng, 0, opts.allowedOperators.length - 1)],
    );

    const results = enumerateAllResults(values, operators);
    // Aday hedefleri: solutionCount istenen aralıkta olan değerler
    const candidates = [...results.entries()].filter(
      ([, count]) => count >= opts.minSolutions && count <= opts.maxSolutions,
    );
    if (candidates.length === 0) continue;

    // Birden fazla aday varsa rastgele birini seç
    const [target, solutionCount] = candidates[randInt(rng, 0, candidates.length - 1)];

    return {
      id: `${idPrefix}-${attempt}`,
      values,
      operators,
      target,
      solutionCount,
      totalArrangements: totalArrangementsFor(opts.cellCount),
    };
  }
  return null;
}
