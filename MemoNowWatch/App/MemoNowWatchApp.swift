import SwiftUI
import WatchConnectivity

@main
struct MemoNowWatchApp: App {
    @State private var boardManager = BoardManager()

    init() {
        WatchConnectivityService.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            WatchBoardListView()
                .environment(boardManager)
                .onAppear {
                    setupSync()
                }
        }
    }

    private func setupSync() {
        // コンテキスト受信時にボードデータを更新
        WatchConnectivityService.shared.onContextReceived = { [weak boardManager] context in
            guard let boardManager,
                  let boardsData = WatchConnectivityService.shared.decodeBoardsFromContext(context) else { return }
            applyBoardsData(boardsData, to: boardManager)
        }

        // 前回受信済みのコンテキストがあれば適用
        if WCSession.default.activationState == .activated {
            let lastContext = WCSession.default.receivedApplicationContext
            if !lastContext.isEmpty,
               let boardsData = WatchConnectivityService.shared.decodeBoardsFromContext(lastContext) {
                applyBoardsData(boardsData, to: boardManager)
            }
        }
    }

    private func applyBoardsData(_ data: [BoardData], to manager: BoardManager) {
        for boardData in data {
            guard boardData.index >= 0, boardData.index < manager.boards.count else { continue }
            let store = manager.boards[boardData.index]
            store.onDataChanged = nil  // 更新中のコールバックを防止
            store.text = boardData.text
            store.fontSize = boardData.fontSize
            let bg = boardData.backgroundColor
            store.backgroundColor = .init(red: bg[0], green: bg[1], blue: bg[2], opacity: bg[3])
            let tc = boardData.textColor
            store.textColor = .init(red: tc[0], green: tc[1], blue: tc[2], opacity: tc[3])
            store.boardName = boardData.boardName
        }
    }
}
