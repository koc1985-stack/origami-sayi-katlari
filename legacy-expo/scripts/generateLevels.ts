// Bir kerelik üretim/doğrulama script'i: v1 için curated level setini üretir,
// solver ile doğrular ve JSON olarak basar. Çıktı elle gözden geçirilip
// src/data/levels.ts içine yapıştırılır (bkz. README).
//
// Çalıştırma: npx tsx scripts/generateLevels.ts

import { LevelDef, Operator } from '../src/types';
import { tryGenerateLevel, GeneratorOptions } from '../src/engine/levelGenerator';

// Basit, tekrarlanabilir (seeded) RNG — mulberry32
function mulberry32(seed: number) {
  let a = seed;
  return function () {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

interface TierSpec {
  label: string;
  count: number;
  cellCount: number;
  minValue: number;
  maxValue: number;
  allowedOperators: Operator[];
  minSolutions: number;
  maxSolutions: number;
}

const tiers: TierSpec[] = [
  // Tier 1 — sadece '+' : katlama jestini öğret, sıra önemsiz (bilinçli olarak kolay)
  { label: 'tutorial-add', count: 2, cellCount: 3, minValue: 1, maxValue: 9,
    allowedOperators: ['+'], minSolutions: 1, maxSolutions: 999 },
  // Tier 2 — '+' ve '×' karışık, 3 hücre: "sıra önemlidir" aha anı, tek doğru sıra
  { label: 'intro-mixed', count: 2, cellCount: 3, minValue: 1, maxValue: 6,
    allowedOperators: ['+', '×'], minSolutions: 1, maxSolutions: 1 },
  // Tier 3 — 4 hücre, karışık, tek doğru sıra
  { label: 'core-4', count: 2, cellCount: 4, minValue: 1, maxValue: 6,
    allowedOperators: ['+', '×'], minSolutions: 1, maxSolutions: 1 },
  // Tier 4 — 5 hücre, karışık, tek veya iki doğru sıra
  { label: 'core-5', count: 2, cellCount: 5, minValue: 1, maxValue: 5,
    allowedOperators: ['+', '×'], minSolutions: 1, maxSolutions: 2 },
  // Tier 5 — 5-6 hücre, capstone, tek doğru sıra
  { label: 'capstone', count: 2, cellCount: 6, minValue: 1, maxValue: 5,
    allowedOperators: ['+', '×'], minSolutions: 1, maxSolutions: 1 },
];

const rng = mulberry32(20260910); // bugünün tarihi = sabit seed

const levels: LevelDef[] = [];
let levelIndex = 1;

for (const tier of tiers) {
  let produced = 0;
  let guard = 0;
  while (produced < tier.count && guard < 200) {
    guard += 1;
    const opts: GeneratorOptions = {
      cellCount: tier.cellCount,
      minValue: tier.minValue,
      maxValue: tier.maxValue,
      allowedOperators: tier.allowedOperators,
      minSolutions: tier.minSolutions,
      maxSolutions: tier.maxSolutions,
      rng,
      maxAttempts: 300,
    };
    const level = tryGenerateLevel(`${tier.label}`, opts);
    if (!level) continue;
    // hedefin 0 veya negatif gibi kafa karıştırıcı olmamasını istiyoruz
    if (level.target <= 0) continue;
    level.id = `L${String(levelIndex).padStart(2, '0')}-${tier.label}`;
    levels.push(level);
    levelIndex += 1;
    produced += 1;
  }
  if (produced < tier.count) {
    console.error(`UYARI: ${tier.label} için sadece ${produced}/${tier.count} level üretilebildi`);
  }
}

console.log(JSON.stringify(levels, null, 2));
console.error(`\nToplam ${levels.length} level üretildi.`);
