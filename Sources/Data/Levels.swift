import Foundation

// v1 curated level seti — legacy-expo/scripts/generateLevels.ts ile üretilip
// solver tarafından doğrulanmıştır (her level'ın solutionCount değeri, hedefe
// ulaşan farklı katlama sırası sayısını gösterir; 1 = tek doğru sıra).

enum Levels {
    static let all: [LevelDef] = [
        LevelDef(
            id: "L01-tutorial-add",
            values: [3, 5, 6],
            operators: [.add, .add],
            target: 14,
            solutionCount: 2,
            totalArrangements: 2
        ),
        LevelDef(
            id: "L02-tutorial-add",
            values: [4, 4, 9],
            operators: [.add, .add],
            target: 17,
            solutionCount: 2,
            totalArrangements: 2
        ),
        LevelDef(
            id: "L03-intro-mixed",
            values: [3, 6, 3],
            operators: [.multiply, .add],
            target: 27,
            solutionCount: 1,
            totalArrangements: 2
        ),
        LevelDef(
            id: "L04-intro-mixed",
            values: [1, 3, 4],
            operators: [.add, .multiply],
            target: 16,
            solutionCount: 1,
            totalArrangements: 2
        ),
        LevelDef(
            id: "L05-core-4",
            values: [3, 1, 4, 2],
            operators: [.multiply, .add, .add],
            target: 17,
            solutionCount: 1,
            totalArrangements: 5
        ),
        LevelDef(
            id: "L06-core-4",
            values: [2, 3, 1, 4],
            operators: [.multiply, .add, .add],
            target: 12,
            solutionCount: 1,
            totalArrangements: 5
        ),
        LevelDef(
            id: "L07-core-5",
            values: [1, 4, 4, 4, 2],
            operators: [.add, .add, .add, .multiply],
            target: 25,
            solutionCount: 2,
            totalArrangements: 14
        ),
        LevelDef(
            id: "L08-core-5",
            values: [1, 2, 2, 2, 1],
            operators: [.add, .multiply, .multiply, .multiply],
            target: 10,
            solutionCount: 2,
            totalArrangements: 14
        ),
        LevelDef(
            id: "L09-capstone",
            values: [2, 3, 1, 4, 3, 3],
            operators: [.multiply, .add, .multiply, .add, .multiply],
            target: 37,
            solutionCount: 1,
            totalArrangements: 42
        ),
        LevelDef(
            id: "L10-capstone",
            values: [4, 1, 5, 5, 2, 5],
            operators: [.add, .multiply, .multiply, .add, .add],
            target: 200,
            solutionCount: 1,
            totalArrangements: 42
        ),
    ]
}
