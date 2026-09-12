import Foundation

// Solver: verilen değer/operatör dizisi için TÜM olası parantezlemeleri
// (katlama sıralarını) deneyip hangi sonuçların kaç farklı yoldan elde
// edildiğini hesaplar (interval DP / Catalan sayımı).
//
// Kullanım: Günün Bulmacası üretiminde zorluk doğrulama, ve oyun içi
// ipucu sisteminde "bu crease'i katlarsam hâlâ hedefe ulaşabilir miyim"
// sorusuna cevap vermek için.

enum Solver {
    /// value -> o değere ulaşan farklı parantezleme (katlama sırası) sayısı.
    static func enumerateAllResults(values: [Int], operators: [GameOperator]) -> [Int: Int] {
        let n = values.count
        guard n > 0 else { return [:] }
        precondition(operators.count == n - 1, "operators.count, values.count - 1 olmalı")

        var memo: [[[Int: Int]?]] = Array(repeating: Array(repeating: nil, count: n), count: n)

        func solve(_ lo: Int, _ hi: Int) -> [Int: Int] {
            if let cached = memo[lo][hi] { return cached }
            if lo == hi {
                let m = [values[lo]: 1]
                memo[lo][hi] = m
                return m
            }
            var result: [Int: Int] = [:]
            for split in lo..<hi {
                let left = solve(lo, split)
                let right = solve(split + 1, hi)
                let op = operators[split]
                for (lv, lc) in left {
                    for (rv, rc) in right {
                        let combined = FoldEngine.applyOperator(op, lv, rv)
                        result[combined, default: 0] += lc * rc
                    }
                }
            }
            memo[lo][hi] = result
            return result
        }

        return solve(0, n - 1)
    }

    static func totalArrangements(for n: Int) -> Int {
        if n <= 1 { return 1 }
        var catalan = [1]
        for i in 1..<n {
            var sum = 0
            for j in 0..<i {
                sum += catalan[j] * catalan[i - 1 - j]
            }
            catalan.append(sum)
        }
        return catalan[n - 1]
    }

    /// Mevcut (kısmen katlanmış) şeritten hâlâ hedefe ulaşılabilecek bir sonraki
    /// crease index'ini bulur — ipucu sistemi için. Katlanabilir yol yoksa nil döner.
    static func hintCreaseIndex(state: StripState, target: Int) -> Int? {
        for creaseIndex in state.creases.indices {
            let next = FoldEngine.foldAt(state, creaseIndex: creaseIndex)
            if next.cells.count == 1 {
                if next.cells[0].value == target { return creaseIndex }
                continue
            }
            let results = enumerateAllResults(
                values: next.cells.map(\.value),
                operators: next.creases.map(\.op)
            )
            if results[target] != nil { return creaseIndex }
        }
        return nil
    }
}
