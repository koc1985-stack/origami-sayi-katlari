import SwiftUI

struct GameView: View {
    let level: LevelDef
    let levelNumber: Int
    let totalLevels: Int
    let onExit: () -> Void
    let onNextLevel: () -> Void
    let hasNextLevel: Bool

    @State private var strip: StripState
    @State private var history: [StripState] = []
    @State private var failedAttempt = false

    init(
        level: LevelDef,
        levelNumber: Int,
        totalLevels: Int,
        onExit: @escaping () -> Void,
        onNextLevel: @escaping () -> Void,
        hasNextLevel: Bool
    ) {
        self.level = level
        self.levelNumber = levelNumber
        self.totalLevels = totalLevels
        self.onExit = onExit
        self.onNextLevel = onNextLevel
        self.hasNextLevel = hasNextLevel
        _strip = State(initialValue: FoldEngine.createStrip(from: level))
    }

    private var finished: Bool { FoldEngine.isFinished(strip) }
    private var won: Bool { finished && FoldEngine.isSolved(strip, target: level.target) }

    private var progressLabel: String { "Level \(levelNumber) / \(totalLevels)" }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: onExit) {
                        Text("‹ Levellar")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: 0x7A5A2E))
                    }
                    Spacer()
                    Text(progressLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: 0xA0895A))
                }
                .padding(.bottom, 16)

                VStack(spacing: 0) {
                    Text("HEDEF")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(2)
                        .foregroundColor(Color(hex: 0xA0895A))
                    Text("\(level.target)")
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundColor(Color(hex: 0x4A3B22))
                }
                .padding(.bottom, 28)

                FlowStripView(strip: strip, finished: finished, onFold: handleFold)
                    .frame(minHeight: 160)

                HStack(spacing: 12) {
                    Button(action: handleUndo) {
                        Text("Geri Al")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: 0x7A5A2E))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: 0xE4C687), lineWidth: 2)
                            )
                            .cornerRadius(12)
                    }
                    .disabled(history.isEmpty)
                    .opacity(history.isEmpty ? 0.4 : 1)

                    Button(action: handleReset) {
                        Text("Baştan")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: 0x7A5A2E))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: 0xE4C687), lineWidth: 2)
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 24)

                if failedAttempt, !won, let first = strip.cells.first {
                    Text("Bu sırayla \(first.value) çıktı, hedef \(level.target). Baştan al, farklı bir sırayla katla.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0xA0522D))
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)

            if won {
                VStack(spacing: 0) {
                    Spacer()
                    winOverlay
                        .padding(.horizontal, 20)
                        .padding(.bottom, 60)
                }
            }
        }
        .background(Color(hex: 0xFAF3E0).ignoresSafeArea())
    }

    private var winOverlay: some View {
        VStack(spacing: 0) {
            Text("Doğru sıra buydu!")
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(Color(hex: 0x4A3B22))
                .padding(.bottom, 4)
            Text("\(level.target) sayısına ulaştın.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0x7A5A2E))
                .padding(.bottom, 16)
            HStack(spacing: 12) {
                Button(action: handleReset) {
                    Text("Tekrar Oyna")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: 0x7A5A2E))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: 0xE4C687), lineWidth: 2)
                        )
                        .cornerRadius(12)
                }
                if hasNextLevel {
                    Button(action: onNextLevel) {
                        Text("Sonraki Level ›")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(Color(hex: 0xE0A62E))
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(24)
        .background(Color(hex: 0xFFF9EC))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: 0xE0A62E), lineWidth: 2)
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    private func animateAndSet(_ next: StripState) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            strip = next
        }
    }

    private func handleFold(_ creaseIndex: Int) {
        guard !finished else { return }
        history.append(strip)
        failedAttempt = false
        let next = FoldEngine.foldAt(strip, creaseIndex: creaseIndex)
        animateAndSet(next)
        if next.cells.count == 1 && next.cells[0].value != level.target {
            failedAttempt = true
        }
    }

    private func handleUndo() {
        guard let previous = history.last else { return }
        history.removeLast()
        failedAttempt = false
        var restored = previous
        restored.undosUsed += 1
        animateAndSet(restored)
    }

    private func handleReset() {
        history = []
        failedAttempt = false
        animateAndSet(FoldEngine.createStrip(from: level))
    }
}

/// Şeridin kendisi: hücreler ve aralarındaki katlama düğmeleri, kaydığında
/// satır kaydıran (RN'deki flexWrap) bir akış düzeni.
private struct FlowStripView: View {
    let strip: StripState
    let finished: Bool
    let onFold: (Int) -> Void

    var body: some View {
        FlowLayout(spacing: 12) {
            ForEach(Array(strip.cells.enumerated()), id: \.element.id) { index, cell in
                CellView(value: cell.value, highlighted: finished)
                if index < strip.creases.count {
                    CreaseButtonView(op: strip.creases[index].op) {
                        onFold(index)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// Basit bir wrap-eden yatay akış (RN'deki flexDirection: row + flexWrap: wrap karşılığı).
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth.isFinite ? maxWidth : rowWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
