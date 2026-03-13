import SwiftUI

struct MemoView: View {
    @Environment(MemoStore.self) private var store
    @State private var showSettings = false

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            TextEditor(text: $store.text)
                .font(.system(size: store.fontSize))
                .foregroundStyle(store.textColor)
                .scrollContentBackground(.hidden)
                .background(store.backgroundColor)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(store.textColor.opacity(0.7))
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsSheet()
                        .environment(store)
                }
        }
    }
}
