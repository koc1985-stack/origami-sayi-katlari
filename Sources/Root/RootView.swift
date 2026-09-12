import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            LevelsTabView()
                .tabItem { Label("Levellar", systemImage: "square.grid.3x3.fill") }

            DailyPuzzleView()
                .tabItem { Label("Günün Bulmacası", systemImage: "calendar") }
        }
        .tint(Color(hex: 0xE0A62E))
    }
}
