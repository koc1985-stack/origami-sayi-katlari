import SwiftUI

struct CellView: View {
    let value: Int
    var highlighted: Bool = false
    var justMerged: Bool = false

    @State private var popScale: CGFloat = 1

    var body: some View {
        Text("\(value)")
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(Color(hex: 0x4A3B22))
            .frame(minWidth: 56, minHeight: 56)
            .padding(.horizontal, 8)
            .background(
                LinearGradient(
                    colors: highlighted
                        ? [Color(hex: 0xFFF1C9), Color(hex: 0xFFE7A8)]
                        : [Color(hex: 0xFDF6E9), Color(hex: 0xF7ECD6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(highlighted ? Color(hex: 0xE0A62E) : Color(hex: 0xE4C687), lineWidth: 2)
            )
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 3)
            .scaleEffect(popScale)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.2).combined(with: .opacity),
                removal: .scale(scale: 0.3).combined(with: .opacity)
            ))
            .onAppear {
                guard justMerged else { return }
                popScale = 1.25
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    popScale = 1
                }
            }
    }
}
