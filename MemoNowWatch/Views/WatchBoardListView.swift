import SwiftUI

struct WatchBoardListView: View {
    @Environment(BoardManager.self) private var manager

    var body: some View {
        TabView {
            ForEach(0..<AppConstants.boardCount, id: \.self) { index in
                WatchMemoView(store: manager.boards[index])
            }
        }
        .tabViewStyle(.page)
    }
}
