import Foundation

// Seedlenebilir RNG (mulberry32 portu) + level üretici. Günün Bulmacası, tarihten
// türetilen sabit bir seed kullanarak her cihazda AYNI bulmacayı üretir.

struct Mulberry32 {
    private var state: UInt32

    init(seed: UInt32) {
        self.state = seed
    }

    /// [0, 1) aralığında bir Double döner (JS mulberry32 ile aynı adımlar).
    mutating func nextUnit() -> Double {
        state = state &+ 0x6D2B79F5
        var t = state
        t = (t ^ (t >> 15)) &* (t | 1)
        t ^= t &+ ((t ^ (t >> 7)) &* (t | 61))
        return Double((t ^ (t >> 14))) / 4294967296.0
    }

    mutating func nextInt(_ lo: Int, _ hi: Int) -> Int {
        Int(nextUnit() * Double(hi - lo + 1)) + lo
    }
}

enum LevelGenerator {
    struct Options {
        var cellCount: Int
        var minValue: Int
        var maxValue: Int
        var allowedOperators: [GameOperator]
        var minSolutions: Int
        var maxSolutions: Int
        var maxAttempts: Int = 500
    }

    static func tryGenerate(idPrefix: String, options: Options, rng: inout Mulberry32) -> LevelDef? {
        for attempt in 0..<options.maxAttempts {
            let values = (0..<options.cellCount).map { _ in
                rng.nextInt(options.minValue, options.maxValue)
            }
            let operators = (0..<(options.cellCount - 1)).map { _ in
                options.allowedOperators[rng.nextInt(0, options.allowedOperators.count - 1)]
            }

            let results = Solver.enumerateAllResults(values: values, operators: operators)
            let candidates = results.filter { $0.value >= options.minSolutions && $0.value <= options.maxSolutions && $0.key > 0 }
            guard !candidates.isEmpty else { continue }

            let sortedKeys = candidates.keys.sorted()
            let target = sortedKeys[rng.nextInt(0, sortedKeys.count - 1)]
            let solutionCount = candidates[target]!

            return LevelDef(
                id: "\(idPrefix)-\(attempt)",
                values: values,
                operators: operators,
                target: target,
                solutionCount: solutionCount,
                totalArrangements: Solver.totalArrangements(for: options.cellCount)
            )
        }
        return nil
    }

    /// Bugünün tarihinden (yerel takvim, YYYYMMDD) sabit bir seed türetir.
    static func seedForToday(calendar: Calendar = .current, date: Date = Date()) -> UInt32 {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 2026
        let m = comps.month ?? 1
        let d = comps.day ?? 1
        return UInt32(y * 10000 + m * 100 + d)
    }

    /// Günün Bulmacası: 5-6 hücre, karışık operatör, tek doğru sıra — zorlu ama adil.
    static func dailyPuzzle(date: Date = Date()) -> LevelDef {
        var rng = Mulberry32(seed: seedForToday(date: date))
        let cellCount = rng.nextInt(0, 1) == 0 ? 5 : 6
        let options = Options(
            cellCount: cellCount,
            minValue: 1,
            maxValue: cellCount == 5 ? 6 : 5,
            allowedOperators: [.add, .multiply],
            minSolutions: 1,
            maxSolutions: 1,
            maxAttempts: 1000
        )
        if let level = tryGenerate(idPrefix: "daily", options: options, rng: &rng) {
            return level
        }
        // Çok düşük ihtimal ama garanti bir düşüş: sabit, her zaman çözülebilir bir bulmaca.
        return LevelDef(
            id: "daily-fallback",
            values: [2, 3, 4, 5],
            operators: [.add, .multiply, .add],
            target: 25,
            solutionCount: 1,
            totalArrangements: 5
        )
    }
}
