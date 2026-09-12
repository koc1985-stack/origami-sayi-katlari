import SwiftUI

struct LevelSelectView: View {
    let levels: [LevelDef]
    @ObservedObject var progress: ProgressStore
    let onSelect: (Int) -> Void

    /// Bir level'ın oynanabilir olması için bir öncekinin çözülmüş olması gerekir.
    private func isUnlocked(_ index: Int) -> Bool {
        index == 0 || progress.stars(for: levels[index - 1].id) > 0
    }

    /// Candy-Crush tarzı hafif zikzak yol hissi için yatay kaydırma.
    private func xOffset(for index: Int) -> CGFloat {
        let pattern: [CGFloat] = [0, 55, 90, 55, 0, -55, -90, -55]
        return pattern[index % pattern.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Origami Sayı Katları")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: 0x4A3B22))
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Text("Doğru sırayla katla, hedefe ulaş.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0xA0895A))
                .multilineTextAlignment(.center)
                .padding(.top, 6)
                .padding(.bottom, 12)

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 28) {
                        ForEach(Array(levels.enumerated()), id: \.element.id) { index, level in
                            LevelNode(
                                number: index + 1,
                                stars: progress.stars(for: level.id),
                                unlocked: isUnlocked(index)
                            ) {
                                if isUnlocked(index) { onSelect(index) }
                            }
                            .offset(x: xOffset(for: index))
                            .id(index)
                        }
                    }
                    .padding(.vertical, 24)
                }
                .onAppear {
                    let firstUnsolved = levels.indices.first { progress.stars(for: levels[$0].id) == 0 } ?? 0
                    proxy.scrollTo(max(0, firstUnsolved - 1), anchor: .top)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: 0xFAF3E0).ignoresSafeArea())
    }
}

private struct LevelNode: View {
    let number: Int
    let stars: Int
    let unlocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                StarsRow(stars: stars)
                ZStack {
                    Circle()
                        .fill(
                            unlocked
                                ? LinearGradient(colors: [Color.white, Color(hex: 0xFDF6E9)], startPoint: .top, endPoint: .bottom)
                                : LinearGradient(colors: [Color(hex: 0xE9E2D2)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle().stroke(unlocked ? Color(hex: 0xE4C687) : Color(hex: 0xD8CFB8), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(unlocked ? 0.1 : 0), radius: 4, y: 2)

                    if unlocked {
                        Text("\(number)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: 0x7A5A2E))
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color(hex: 0xB0A588))
                    }
                }
            }
        }
        .disabled(!unlocked)
    }
}

private struct StarsRow: View {
    let stars: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < stars ? "star.fill" : "star")
                    .font(.system(size: 10))
                    .foregroundColor(i < stars ? Color(hex: 0xE0A62E) : Color(hex: 0xD8CFB8))
            }
        }
        .opacity(stars > 0 ? 1 : 0.5)
    }
}
