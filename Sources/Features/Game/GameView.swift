import SwiftUI

struct GameView: View {
    let level: LevelDef
    /// Level modunda "Level X / Y" başlığı; günün bulmacasında nil.
    let levelNumber: Int?
    let totalLevels: Int?
    /// Level modunda "‹ Levellar" geri dönüşü; günün bulmacasında gizli (sekme çubuğu var).
    let showExitButton: Bool
    let onExit: () -> Void
    let onNextLevel: (() -> Void)?
    let hasNextLevel: Bool
    let onSolved: (SolveResult) -> Void

    @State private var strip: StripState
    @State private var history: [StripState] = []
    @State private var foldOrder: [GameOperator] = []
    @State private var resetsUsed = 0
    @State private var statusMessage: String?
    @State private var hasReportedSolve = false
    @State private var hintedCreaseIndex: Int?
    @State private var shakeTrigger = 0
    @State private var pulseID: UUID?

    init(
        level: LevelDef,
        levelNumber: Int? = nil,
        totalLevels: Int? = nil,
        showExitButton: Bool = true,
        onExit: @escaping () -> Void = {},
        onNextLevel: (() -> Void)? = nil,
        hasNextLevel: Bool = false,
        onSolved: @escaping (SolveResult) -> Void
    ) {
        self.level = level
        self.levelNumber = levelNumber
        self.totalLevels = totalLevels
        self.showExitButton = showExitButton
        self.onExit = onExit
        self.onNextLevel = onNextLevel
        self.hasNextLevel = hasNextLevel
        self.onSolved = onSolved
        _strip = State(initialValue: FoldEngine.createStrip(from: level))
    }

    private var finished: Bool { FoldEngine.isFinished(strip) }
    private var won: Bool { finished && FoldEngine.isSolved(strip, target: level.target) }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header

                VStack(spacing: 0) {
                    Text("HEDEF")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(2)
                        .foregroundColor(Color(hex: 0xA0895A))
                    Text("\(level.target)")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: 0x4A3B22))
                }
                .padding(.bottom, 28)

                ZStack {
                    if let pulseID {
                        FoldPulseView(color: Color(hex: 0xE0A62E))
                            .id(pulseID)
                    }
                    FlowStripView(strip: strip, finished: finished, hintedCreaseIndex: hintedCreaseIndex, onFold: handleFold)
                }
                .frame(minHeight: 160)
                .modifier(ShakeEffect(shakes: CGFloat(shakeTrigger)))

                controls

                if let statusMessage, !won {
                    Text(statusMessage)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0xA0522D))
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                        .transition(.opacity)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)

            if statusMessage != nil, !won {
                Color.red.opacity(0.06).ignoresSafeArea().allowsHitTesting(false)
            }

            if won {
                ConfettiView()
                VStack(spacing: 0) {
                    Spacer()
                    winOverlay
                        .padding(.horizontal, 20)
                        .padding(.bottom, 60)
                }
            }
        }
        .background(Color(hex: 0xFAF3E0).ignoresSafeArea())
        .onChange(of: won) { _, isWon in
            guard isWon, !hasReportedSolve else { return }
            hasReportedSolve = true
            Haptics.success()
            onSolved(SolveResult(levelID: level.id, resetsUsed: resetsUsed, undosUsed: strip.undosUsed, foldOrder: foldOrder))
        }
    }

    private var header: some View {
        HStack {
            if showExitButton {
                Button(action: onExit) {
                    Text("‹ Levellar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: 0x7A5A2E))
                }
            } else {
                Color.clear.frame(width: 1, height: 1)
            }
            Spacer()
            if let levelNumber, let totalLevels {
                Text("Level \(levelNumber) / \(totalLevels)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: 0xA0895A))
            } else {
                Text("Günün Bulmacası")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: 0xA0895A))
            }
            Spacer()
            Button(action: handleHint) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: 0xE0A62E))
            }
            .opacity(finished ? 0.3 : 1)
            .disabled(finished)
        }
        .padding(.bottom, 16)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            PillButton(title: "Geri Al", disabled: history.isEmpty, action: handleUndo)
            PillButton(title: "Baştan", action: handleReset)
        }
        .padding(.top, 24)
    }

    private var winOverlay: some View {
        VStack(spacing: 0) {
            Text("Doğru sıra buydu!")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: 0x4A3B22))
                .padding(.bottom, 4)
            Text("\(level.target) sayısına ulaştın.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0x7A5A2E))
                .padding(.bottom, 16)
            HStack(spacing: 12) {
                PillButton(title: "Tekrar Oyna", action: handleReset)
                if hasNextLevel, let onNextLevel {
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
        .transition(.scale.combined(with: .opacity))
    }

    private func animateAndSet(_ next: StripState) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
            strip = next
        }
    }

    private func handleFold(_ creaseIndex: Int) {
        guard !finished else { return }
        Haptics.fold()
        history.append(strip)
        foldOrder.append(strip.creases[creaseIndex].op)
        statusMessage = nil
        hintedCreaseIndex = nil
        pulseID = UUID()
        let next = FoldEngine.foldAt(strip, creaseIndex: creaseIndex)
        animateAndSet(next)
        if next.cells.count == 1 && next.cells[0].value != level.target {
            statusMessage = "Bu sırayla \(next.cells[0].value) çıktı, hedef \(level.target). Baştan al, farklı bir sırayla katla."
            Haptics.failure()
            withAnimation(.default) { shakeTrigger += 1 }
        }
    }

    private func handleUndo() {
        guard let previous = history.last else { return }
        Haptics.tap()
        history.removeLast()
        foldOrder.removeLast()
        statusMessage = nil
        hintedCreaseIndex = nil
        var restored = previous
        restored.undosUsed += 1
        animateAndSet(restored)
    }

    private func handleReset() {
        Haptics.tap()
        if !won {
            resetsUsed += 1
        }
        history = []
        foldOrder = []
        statusMessage = nil
        hasReportedSolve = false
        hintedCreaseIndex = nil
        animateAndSet(FoldEngine.createStrip(from: level))
    }

    private func handleHint() {
        guard !finished else { return }
        Haptics.tap()
        let hint = Solver.hintCreaseIndex(state: strip, target: level.target)
        withAnimation { hintedCreaseIndex = hint }
        if hint == nil {
            statusMessage = "Bu yoldan hedefe ulaşılamıyor. Baştan al, farklı bir sırayla dene."
            Haptics.failure()
            withAnimation(.default) { shakeTrigger += 1 }
        }
    }
}

/// Şeridin kendisi: hücreler ve aralarındaki katlama düğmeleri, kaydığında
/// satır kaydıran (RN'deki flexWrap) bir akış düzeni.
private struct FlowStripView: View {
    let strip: StripState
    let finished: Bool
    let hintedCreaseIndex: Int?
    let onFold: (Int) -> Void

    var body: some View {
        FlowLayout(spacing: 12) {
            ForEach(Array(strip.cells.enumerated()), id: \.element.id) { index, cell in
                CellView(value: cell.value, highlighted: finished, justMerged: cell.id.hasPrefix("m-"))
                if index < strip.creases.count {
                    CreaseButtonView(op: strip.creases[index].op, hinted: hintedCreaseIndex == index) {
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

private struct PillButton: View {
    let title: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
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
        .disabled(disabled)
        .opacity(disabled ? 0.4 : 1)
    }
}

/// Yanlış sonuçta şeridi hafifçe salla — "hayır, bu değil" hissi.
private struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let offset = sin(shakes * .pi * 6) * 6
        return ProjectionTransform(CGAffineTransform(translationX: offset, y: 0))
    }
}
