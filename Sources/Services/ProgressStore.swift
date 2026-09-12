import Foundation

/// Basit UserDefaults tabanlı ilerleme kaydı: level yıldızları + günün bulmacası serisi.
/// Her katlama tam olarak bir hücre azalttığı için "hamle sayısı" hep sabittir (n-1);
/// bu yüzden yıldız, hamle sayısına değil "kaç deneme (Baştan/undo) harcandı"na dayanır.
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let stars = "progress.stars" // [String: Int] level id -> 1...3
        static let dailyStreak = "progress.dailyStreak"
        static let dailyBestStreak = "progress.dailyBestStreak"
        static let lastDailyDateKey = "progress.lastDailyDateKey" // "yyyyMMdd"
        static let lastDailyShareText = "progress.lastDailyShareText"
    }

    @Published private(set) var stars: [String: Int]
    @Published private(set) var dailyStreak: Int
    @Published private(set) var dailyBestStreak: Int
    @Published private(set) var lastDailyDateKey: String?
    @Published private(set) var lastDailyShareText: String?

    private init() {
        stars = (UserDefaults.standard.dictionary(forKey: Keys.stars) as? [String: Int]) ?? [:]
        dailyStreak = UserDefaults.standard.integer(forKey: Keys.dailyStreak)
        dailyBestStreak = UserDefaults.standard.integer(forKey: Keys.dailyBestStreak)
        lastDailyDateKey = UserDefaults.standard.string(forKey: Keys.lastDailyDateKey)
        lastDailyShareText = UserDefaults.standard.string(forKey: Keys.lastDailyShareText)
    }

    func stars(for levelID: String) -> Int { stars[levelID] ?? 0 }

    func recordLevelSolved(id: String, resetsUsed: Int, undosUsed: Int) {
        let earned: Int
        if resetsUsed == 0 && undosUsed == 0 {
            earned = 3
        } else if resetsUsed == 0 {
            earned = 2
        } else {
            earned = 1
        }
        let best = max(earned, stars[id] ?? 0)
        stars[id] = best
        defaults.set(stars, forKey: Keys.stars)
    }

    static func dateKey(_ date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d%02d%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    var isDailySolvedToday: Bool {
        lastDailyDateKey == Self.dateKey(Date())
    }

    /// Günün bulmacası çözüldüğünde çağrılır. `shareText` daha sonra tekrar
    /// paylaşabilmek için saklanır (uygulama kapanıp açılsa bile).
    func recordDailySolved(shareText: String, on date: Date = Date(), calendar: Calendar = .current) {
        let todayKey = Self.dateKey(date, calendar: calendar)
        guard lastDailyDateKey != todayKey else { return }

        if let last = lastDailyDateKey,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: date),
           last == Self.dateKey(yesterday, calendar: calendar) {
            dailyStreak += 1
        } else {
            dailyStreak = 1
        }
        dailyBestStreak = max(dailyBestStreak, dailyStreak)
        lastDailyDateKey = todayKey
        lastDailyShareText = shareText

        defaults.set(dailyStreak, forKey: Keys.dailyStreak)
        defaults.set(dailyBestStreak, forKey: Keys.dailyBestStreak)
        defaults.set(lastDailyDateKey, forKey: Keys.lastDailyDateKey)
        defaults.set(lastDailyShareText, forKey: Keys.lastDailyShareText)
    }

    /// Bugünkü seri kopmuşsa (son çözüm dünden eskiyse) UI'da 0 göstermek için.
    var currentStreakDisplay: Int {
        guard let last = lastDailyDateKey else { return 0 }
        let today = Self.dateKey(Date())
        if last == today { return dailyStreak }
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
           last == Self.dateKey(yesterday) {
            return dailyStreak
        }
        return 0
    }
}
