import SwiftUI

struct CreaseButtonView: View {
    let op: GameOperator
    var hinted: Bool = false
    let onPress: () -> Void

    @State private var hintPulse = false

    private var color: Color {
        switch op {
        case .add: return Color(hex: 0x3E8E5A)
        case .multiply: return Color(hex: 0x7A4FC9)
        }
    }

    var body: some View {
        Button(action: onPress) {
            Text(op.rawValue)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(Color.white)
                .overlay(Circle().stroke(color, lineWidth: hinted ? 3 : 2))
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.5), lineWidth: 2)
                        .scaleEffect(hintPulse ? 1.5 : 1)
                        .opacity(hinted ? (hintPulse ? 0 : 0.8) : 0)
                )
                .clipShape(Circle())
                .shadow(color: hinted ? color.opacity(0.5) : .clear, radius: 6)
        }
        .accessibilityLabel("\(op.rawValue) işlemiyle katla")
        .padding(.horizontal, 2)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.2).combined(with: .opacity),
            removal: .scale(scale: 0.3).combined(with: .opacity)
        ))
        .onAppear { updatePulse() }
        .onChange(of: hinted) { _, _ in updatePulse() }
    }

    private func updatePulse() {
        guard hinted else { hintPulse = false; return }
        hintPulse = false
        withAnimation(.easeOut(duration: 0.9).repeatForever(autoreverses: false)) {
            hintPulse = true
        }
    }
}
