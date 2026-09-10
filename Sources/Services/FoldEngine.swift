import Foundation

// Katlama motoru: bir StripState üzerinde tek bir katlama adımını uygular.
//
// Kural: creases[i], cells[i] ile cells[i+1] arasındadır. O çizgiyi
// katladığında iki hücre operatöre göre TEK hücrede birleşir, o crease
// silinir, ondan sonraki crease'ler bir kayar. "+" ve "×" değişmeli
// (commutative) olduğu için "hangi hücre üstte, hangisi altta katlanıyor"
// sonucu etkilemez — bu bilinçli bir v1 tasarım kararı.

enum FoldEngine {
    private static var idCounter = 0

    private static func nextId(_ prefix: String) -> String {
        idCounter += 1
        return "\(prefix)-\(idCounter)"
    }

    static func applyOperator(_ op: GameOperator, _ a: Int, _ b: Int) -> Int {
        switch op {
        case .add:
            return a + b
        case .multiply:
            return a * b
        }
    }

    static func createStrip(from level: LevelDef) -> StripState {
        let cells = level.values.enumerated().map { index, value in
            GameCell(id: "c-\(level.id)-\(index)", value: value)
        }
        let creases = level.operators.enumerated().map { index, op in
            Crease(id: "cr-\(level.id)-\(index)", op: op)
        }
        return StripState(cells: cells, creases: creases, foldCount: 0, undosUsed: 0)
    }

    /// creaseIndex konumunda katlama yapar, yeni bir StripState döner. Girdi mutate edilmez.
    static func foldAt(_ state: StripState, creaseIndex: Int) -> StripState {
        precondition(creaseIndex >= 0 && creaseIndex < state.creases.count, "Geçersiz crease index: \(creaseIndex)")

        let left = state.cells[creaseIndex]
        let right = state.cells[creaseIndex + 1]
        let op = state.creases[creaseIndex].op
        let mergedValue = applyOperator(op, left.value, right.value)
        let merged = GameCell(id: nextId("m"), value: mergedValue)

        var newCells = Array(state.cells[0..<creaseIndex])
        newCells.append(merged)
        newCells.append(contentsOf: state.cells[(creaseIndex + 2)...])

        var newCreases = Array(state.creases[0..<creaseIndex])
        newCreases.append(contentsOf: state.creases[(creaseIndex + 1)...])

        return StripState(
            cells: newCells,
            creases: newCreases,
            foldCount: state.foldCount + 1,
            undosUsed: state.undosUsed
        )
    }

    static func isSolved(_ state: StripState, target: Int) -> Bool {
        state.cells.count == 1 && state.cells[0].value == target
    }

    static func isFinished(_ state: StripState) -> Bool {
        state.cells.count == 1
    }
}
