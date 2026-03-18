import SwiftUI

@main
struct WidgetMemoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var boardManager = BoardManager()

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
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                boardManager.reloadAllWidgets()
            }
        }
    }
}
