import SwiftUI

@main
struct WidgetMemoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var boardManager = BoardManager()

    init() {
        #if os(iOS)
        WatchConnectivityService.shared.activate()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(boardManager)
                .onOpenURL { url in
                    guard url.scheme == "memonow",
                          url.host == "board",
                          let indexStr = url.pathComponents.last,
                          let index = Int(indexStr),
                          (0..<AppConstants.boardCount).contains(index) else { return }
                    boardManager.selectedIndex = index
                }
                .onAppear {
                    #if os(iOS)
                    setupWatchSync()
                    #endif
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                boardManager.reloadAllWidgets()
                #if os(iOS)
                WatchConnectivityService.shared.pushAllBoards(boardManager.boards)
                #endif
            }
        }
    }

    #if os(iOS)
    private func setupWatchSync() {
        // 各ボードのデータ変更時に Watch へ push
        for board in boardManager.boards {
            board.onDataChanged = { [weak boardManager] in
                guard let boards = boardManager?.boards else { return }
                WatchConnectivityService.shared.pushAllBoards(boards)
            }
        }
        // 初回起動時に最新データを push
        WatchConnectivityService.shared.pushAllBoards(boardManager.boards)
    }
    #endif
}
