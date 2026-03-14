import SwiftUI

@main
struct WidgetMemoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var store = MemoStore()

    var body: some Scene {
        WindowGroup {
            MemoView()
                .environment(store)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                store.reloadWidgetsNow()
            }
        }
    }
}
