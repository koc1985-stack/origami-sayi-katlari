import SwiftUI

struct DailyPuzzleView: View {
    @StateObject private var progress = ProgressStore.shared
    private let todayLevel = LevelGenerator.dailyPuzzle()

    var body: some View {
        Group {
            if progress.isDailySolvedToday {
                SolvedTodayView(
                    dayNumber: ShareCardBuilder.dayNumber(),
                    streak: progress.currentStreakDisplay,
                    shareText: progress.lastDailyShareText ?? ""
                )
            } else {
                GameView(
                    level: todayLevel,
                    showExitButton: false,
                    onSolved: { result in
                        let text = ShareCardBuilder.shareText(
                            level: todayLevel,
                            foldOrder: result.foldOrder,
                            streak: progress.currentStreakDisplay + 1
                        )
                        progress.recordDailySolved(shareText: text)
                    }
                )
            }
        }
        .background(Color(hex: 0xFAF3E0).ignoresSafeArea())
    }
}

private struct SolvedTodayView: View {
    let dayNumber: Int
    let streak: Int
    let shareText: String

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundColor(Color(hex: 0xE0A62E))

            Text("Gün #\(dayNumber) tamamlandı!")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: 0x4A3B22))

            HStack(spacing: 6) {
                Image(systemName: "flame.fill").foregroundColor(.orange)
                Text("\(streak) gün üst üste")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: 0x7A5A2E))
            }

            Text("Yarın yeni bir bulmaca seni bekliyor.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0xA0895A))

            if !shareText.isEmpty {
                ShareLink(item: shareText) {
                    Label("Sonucu Paylaş", systemImage: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color(hex: 0xE0A62E))
                        .cornerRadius(14)
                }
                .padding(.top, 8)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
