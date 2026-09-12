import Foundation

enum ShareCardBuilder {
    /// Oyunun piyasaya çıktığı gün = Gün #1. Wordle tarzı "Gün #N" numaralandırması için.
    private static let epoch = DateComponents(calendar: .current, year: 2026, month: 9, day: 10).date!

    static func dayNumber(for date: Date = Date(), calendar: Calendar = .current) -> Int {
        let days = calendar.dateComponents([.day], from: epoch, to: date).day ?? 0
        return max(1, days + 1)
    }

    private static func emoji(for op: GameOperator) -> String {
        switch op {
        case .add: return "🟩"
        case .multiply: return "🟪"
        }
    }

    static func shareText(level: LevelDef, foldOrder: [GameOperator], streak: Int) -> String {
        let squares = foldOrder.map(emoji(for:)).joined()
        let dayLine = "Origami Sayı Katları 🎯 Gün #\(dayNumber())"
        let resultLine = "\(squares) → \(level.target)"
        let streakLine = streak > 1 ? "🔥 \(streak) gün üst üste" : "İlk çözüşüm!"
        return [dayLine, resultLine, streakLine].joined(separator: "\n")
    }
}
