import SwiftUI

struct RootView: View {
    @State private var selectedIndex: Int?

    var body: some View {
        Group {
            if let selectedIndex {
                GameView(
                    level: Levels.all[selectedIndex],
                    levelNumber: selectedIndex + 1,
                    totalLevels: Levels.all.count,
                    onExit: { self.selectedIndex = nil },
                    onNextLevel: {
                        if selectedIndex + 1 < Levels.all.count {
                            self.selectedIndex = selectedIndex + 1
                        }
                    },
                    hasNextLevel: selectedIndex + 1 < Levels.all.count
                )
            } else {
                LevelSelectView(levels: Levels.all) { index in
                    selectedIndex = index
                }
            }
        }
        .background(Color(hex: 0xFAF3E0).ignoresSafeArea())
    }
}
