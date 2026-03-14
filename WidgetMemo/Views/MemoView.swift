import SwiftUI

struct MemoView: View {
    @Environment(MemoStore.self) private var store
    @State private var showSettings = false

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            ZStack {
                ZStack {
                    Color.white
                    LinearGradient(
                        colors: [
                            store.backgroundColor,
                            store.backgroundColor.opacity(0.4),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()

                TextEditor(text: $store.text)
                    .font(.system(size: store.fontSize))
                    .foregroundStyle(store.textColor)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17, weight: .light))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
                    .environment(store)
            }
        }
        .preferredColorScheme(.light)
    }
}
