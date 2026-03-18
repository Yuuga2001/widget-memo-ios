import SwiftUI

struct MainTabView: View {
    @Environment(BoardManager.self) private var manager

    var body: some View {
        @Bindable var manager = manager

        TabView(selection: $manager.selectedIndex) {
            ForEach(0..<AppConstants.boardCount, id: \.self) { index in
                MemoView()
                    .environment(manager.boards[index])
                    .tabItem {
                        Label(manager.boards[index].boardName, systemImage: "note.text")
                    }
                    .tag(index)
            }
        }
    }
}
