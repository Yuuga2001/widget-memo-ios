import SwiftUI

struct MemoView: View {
    @Environment(MemoStore.self) private var store
    @Environment(\.undoManager) private var undoManager
    @State private var showSettings = false
    @State private var isEditingName = false
    @FocusState private var isNameFieldFocused: Bool

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
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 12) {
                        Button {
                            undoManager?.undo()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(.secondary)
                                .opacity(undoManager?.canUndo == true ? 1.0 : 0.3)
                        }
                        .disabled(undoManager?.canUndo != true)

                        Button {
                            undoManager?.redo()
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(.secondary)
                                .opacity(undoManager?.canRedo == true ? 1.0 : 0.3)
                        }
                        .disabled(undoManager?.canRedo != true)
                    }
                }
                ToolbarItem(placement: .principal) {
                    if isEditingName {
                        TextField("ボード名", text: $store.boardName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 150)
                            .focused($isNameFieldFocused)
                            .onSubmit {
                                isEditingName = false
                            }
                            .onChange(of: isNameFieldFocused) { _, focused in
                                if !focused {
                                    isEditingName = false
                                }
                            }
                    } else {
                        Text(store.boardName)
                            .font(.headline)
                            .foregroundStyle(store.textColor.opacity(0.8))
                            .onTapGesture {
                                isEditingName = true
                                isNameFieldFocused = true
                            }
                    }
                }
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
