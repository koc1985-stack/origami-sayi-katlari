import SwiftUI

/// Level/günün bulmacası çözülünce kısa bir kutlama patlaması. Harici kütüphane yok —
/// birkaç düzine renkli parça, merkezden rastgele yönlere fırlayıp döner ve söner.
struct ConfettiView: View {
    private struct Piece: Identifiable {
        let id = UUID()
        let color: Color
        let angle: Double
        let distance: CGFloat
        let rotation: Double
        let size: CGFloat
        let delay: Double
    }

    @State private var animate = false
    private let pieces: [Piece]

    private static let palette: [Color] = [
        Color(hex: 0xE0A62E), Color(hex: 0x3E8E5A), Color(hex: 0x7A4FC9),
        Color(hex: 0xE0725E), Color(hex: 0x4A9BD1),
    ]

    init(pieceCount: Int = 28) {
        pieces = (0..<pieceCount).map { _ in
            Piece(
                color: Self.palette.randomElement()!,
                angle: Double.random(in: 0..<360),
                distance: CGFloat.random(in: 90...200),
                rotation: Double.random(in: -540...540),
                size: CGFloat.random(in: 6...11),
                delay: Double.random(in: 0...0.12)
            )
        }
    }

    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                RoundedRectangle(cornerRadius: 2)
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size * 0.6)
                    .rotationEffect(.degrees(animate ? piece.rotation : 0))
                    .offset(
                        x: animate ? CGFloat(cos(piece.angle * .pi / 180)) * piece.distance : 0,
                        y: animate ? CGFloat(sin(piece.angle * .pi / 180)) * piece.distance : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 0.9).delay(piece.delay),
                        value: animate
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
}
