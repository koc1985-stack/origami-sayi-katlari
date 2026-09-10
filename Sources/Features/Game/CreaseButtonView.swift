import SwiftUI

struct CreaseButtonView: View {
    let op: GameOperator
    let onPress: () -> Void

    private var color: Color {
        switch op {
        case .add: return Color(hex: 0x3E8E5A)
        case .multiply: return Color(hex: 0x7A4FC9)
        }
    }

    var body: some View {
        Button(action: onPress) {
            Text(op.rawValue)
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(Color.white)
                .overlay(Circle().stroke(color, lineWidth: 2))
                .clipShape(Circle())
        }
        .accessibilityLabel("\(op.rawValue) işlemiyle katla")
        .padding(.horizontal, 2)
    }
}
