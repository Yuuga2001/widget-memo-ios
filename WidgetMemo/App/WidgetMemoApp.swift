import SwiftUI

@main
struct WidgetMemoApp: App {
    @State private var store = MemoStore()

    var body: some Scene {
        WindowGroup {
            MemoView()
                .environment(store)
        }
    }
}
