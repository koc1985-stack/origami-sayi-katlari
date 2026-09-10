import SwiftUI

struct LevelSelectView: View {
    let levels: [LevelDef]
    let onSelect: (Int) -> Void

    private let columns = Array(repeating: GridItem(.fixed(60), spacing: 14), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            Text("Origami Sayı Katları")
                .font(.system(size: 26, weight: .heavy))
                .foregroundColor(Color(hex: 0x4A3B22))
                .multilineTextAlignment(.center)
                .padding(.top, 80)

            Text("Doğru sırayla katla, hedefe ulaş.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: 0xA0895A))
                .multilineTextAlignment(.center)
                .padding(.top, 6)
                .padding(.bottom, 32)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Array(levels.enumerated()), id: \.element.id) { index, _ in
                    Button {
                        onSelect(index)
                    } label: {
                        Text("\(index + 1)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: 0x7A5A2E))
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: 0xE4C687), lineWidth: 2)
                            )
                            .cornerRadius(16)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color(hex: 0xFAF3E0).ignoresSafeArea())
    }
}
