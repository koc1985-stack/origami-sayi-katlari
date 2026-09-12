import SwiftUI

/// Bir katlama olduğunda dokunulan crease noktasında genişleyip sönen halka —
/// katlamaya görsel bir "enerji" hissi verir.
struct FoldPulseView: View {
    let color: Color
    @State private var expand = false

    var body: some View {
        Circle()
            .stroke(color, lineWidth: 3)
            .frame(width: expand ? 90 : 10, height: expand ? 90 : 10)
            .opacity(expand ? 0 : 0.8)
            .onAppear {
                withAnimation(.easeOut(duration: 0.45)) {
                    expand = true
                }
            }
            .allowsHitTesting(false)
    }
}
