// Doğrulama script'i: her level için TÜM olası tıklama sıralarını
// (permütasyonları) foldEngine ile fiilen simüle eder ve:
//  1) Motorun ürettiği "ulaşılabilir değerler" kümesinin solver'ın
//     hesapladığı kümeyle birebir aynı olduğunu,
//  2) Hedefe en az bir sırayla ulaşılabildiğini,
//  3) solutionCount < totalArrangements olan level'larda hedefin GERÇEKTEN
//     bazı sıralarda tutmadığını (yani bulmacanın triviyal olmadığını)
// doğrular.
//
// Çalıştırma: npx tsx scripts/verifyLevels.ts

import { levels } from '../src/data/levels';
import { createStripFromLevel, foldAt } from '../src/engine/foldEngine';
import { enumerateAllResults } from '../src/engine/solver';

function permutations(arr: number[]): number[][] {
  if (arr.length <= 1) return [arr];
  const result: number[][] = [];
  for (let i = 0; i < arr.length; i += 1) {
    const rest = [...arr.slice(0, i), ...arr.slice(i + 1)];
    for (const p of permutations(rest)) {
      result.push([arr[i], ...p]);
    }
  }
  return result;
}

let allOk = true;

for (const level of levels) {
  const n = level.values.length;
  const creaseIndices = Array.from({ length: n - 1 }, (_, i) => i);
  const clickOrders = permutations(creaseIndices);

  const achievedValues = new Set<number>();
  let targetHits = 0;

  for (const order of clickOrders) {
    let strip = createStripFromLevel(level);
    // Not: crease index'leri her fold sonrası kayar. Bu yüzden "order" listesindeki
    // her adımı, o adımdaki MEVCUT crease sayısına göre normalize etmemiz lazım.
    // Basit yaklaşım: her adımda kalan crease index'lerinden order'daki bir
    // sonraki "orijinal" index'e karşılık geleni bulmak yerine, doğrudan
    // 0..remaining-1 aralığında rastgele değil, permütasyonun kendisini
    // "her adımda mevcut olan en küçük index'ten başlayarak sırayla" değil,
    // gerçek bir crease-id takip sistemiyle simüle ediyoruz:
    const remainingOriginalIds = level.operators.map((_, i) => i);
    let liveIds = [...remainingOriginalIds];
    for (const originalIdx of order) {
      const liveIndex = liveIds.indexOf(originalIdx);
      strip = foldAt(strip, liveIndex);
      liveIds.splice(liveIndex, 1);
    }
    achievedValues.add(strip.cells[0].value);
    if (strip.cells[0].value === level.target) targetHits += 1;
  }

  const solverResults = enumerateAllResults(level.values, level.operators);
  const solverValues = new Set(solverResults.keys());

  const setsEqual =
    achievedValues.size === solverValues.size &&
    [...achievedValues].every((v) => solverValues.has(v));

  const reachable = targetHits > 0;
  const nonTrivial = level.solutionCount >= level.totalArrangements || targetHits < clickOrders.length;

  const ok = setsEqual && reachable && nonTrivial;
  if (!ok) allOk = false;

  console.log(
    `${level.id}: setsEqual=${setsEqual} reachable=${reachable} (${targetHits}/${clickOrders.length} tıklama sırası hedefe ulaşıyor) nonTrivial=${nonTrivial} => ${ok ? 'OK' : 'HATA'}`,
  );
}

console.log(allOk ? '\nTüm level\'lar doğrulandı.' : '\nBAZI LEVELLAR HATALI!');
process.exit(allOk ? 0 : 1);
