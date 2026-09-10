import Foundation

// Origami Sayı Katları — temel tipler
//
// v1 kapsamı: tek boyutlu (1D) şerit, sadece "+" ve "×" operatörleri.
// "−" ve "÷" ile 2D ızgara sonraki sürümlere bırakıldı.

enum GameOperator: String {
    case add = "+"
    case multiply = "×"
}

/// Şerit üzerindeki bir hücre (sayı).
struct GameCell: Identifiable, Equatable {
    /// Animasyon/liste anahtarı için sabit kimlik.
    let id: String
    let value: Int
}

/// İki komşu hücre arasındaki katlama çizgisi.
struct Crease: Identifiable, Equatable {
    let id: String
    let op: GameOperator
}

/// Bir level'ın statik tanımı.
struct LevelDef: Identifiable {
    let id: String
    /// Başlangıç hücre değerleri, soldan sağa.
    let values: [Int]
    /// values.count - 1 uzunluğunda operatör dizisi.
    let operators: [GameOperator]
    /// Oyuncunun ulaşması gereken hedef sayı.
    let target: Int
    /// Solver tarafından hesaplanan: kaç farklı katlama SIRASI hedefe ulaşıyor.
    let solutionCount: Int
    /// Bu parantezlemenin toplam kaç farklı sonucu olabildiği (Catalan(n-1)).
    let totalArrangements: Int
}

/// Oynanabilir şeridin canlı durumu.
struct StripState: Equatable {
    var cells: [GameCell]
    var creases: [Crease] // cells.count - 1 uzunluğunda
    var foldCount: Int
    var undosUsed: Int
}
