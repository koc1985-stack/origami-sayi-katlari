import SwiftUI

struct CellView: View {
    let value: Int
    var highlighted: Bool = false

    var body: some View {
        Text("\(value)")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color(hex: 0x4A3B22))
            .frame(minWidth: 56, minHeight: 56)
            .padding(.horizontal, 8)
            .background(highlighted ? Color(hex: 0xFFF1C9) : Color(hex: 0xFDF6E9))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(highlighted ? Color(hex: 0xE0A62E) : Color(hex: 0xE4C687), lineWidth: 2)
            )
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
    }
}
