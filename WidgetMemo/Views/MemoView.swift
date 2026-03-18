import SwiftUI

struct MemoView: View {
    @Environment(MemoStore.self) private var store
    @State private var showSettings = false
    @State private var isEditingName = false
    @State private var canUndo = false
    @State private var canRedo = false
    @State private var textUndoManager = TextUndoManager()
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
                            performUndo()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(.secondary)
                                .opacity(canUndo ? 1.0 : 0.3)
                        }
                        .disabled(!canUndo)
                        .accessibilityIdentifier("undoButton")

                        Button {
                            performRedo()
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(.secondary)
                                .opacity(canRedo ? 1.0 : 0.3)
                        }
                        .disabled(!canRedo)
                        .accessibilityIdentifier("redoButton")
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
        .onAppear {
            textUndoManager.initialize(with: store.text)
        }
        .onChange(of: store.text) { oldValue, newValue in
            textUndoManager.textDidChange(newValue)
            updateUndoState()
        }
    }

    private func performUndo() {
        if let text = textUndoManager.undo() {
            store.text = text
            updateUndoState()
        }
    }

    private func performRedo() {
        if let text = textUndoManager.redo() {
            store.text = text
            updateUndoState()
        }
    }

    private func updateUndoState() {
        canUndo = textUndoManager.canUndo
        canRedo = textUndoManager.canRedo
    }
}

// MARK: - TextUndoManager

/// テキスト編集の Undo/Redo を管理するシンプルなスタックベースの仕組み
struct TextUndoManager {
    private var undoStack: [String] = []
    private var redoStack: [String] = []
    private var isPerformingUndoRedo = false

    var canUndo: Bool { undoStack.count > 1 }
    var canRedo: Bool { !redoStack.isEmpty }

    /// 初期テキストをセット
    mutating func initialize(with text: String) {
        if undoStack.isEmpty {
            undoStack = [text]
            redoStack = []
        }
    }

    /// テキストが変更された時に呼ばれる
    mutating func textDidChange(_ newText: String) {
        guard !isPerformingUndoRedo else { return }
        // 直前と同じなら無視
        guard undoStack.last != newText else { return }
        undoStack.append(newText)
        redoStack.removeAll()
    }

    /// Undo: 1つ前の状態を返す
    mutating func undo() -> String? {
        guard canUndo else { return nil }
        let current = undoStack.removeLast()
        redoStack.append(current)
        isPerformingUndoRedo = true
        defer { isPerformingUndoRedo = false }
        return undoStack.last
    }

    /// Redo: Undo で戻した状態を復元
    mutating func redo() -> String? {
        guard canRedo else { return nil }
        let text = redoStack.removeLast()
        undoStack.append(text)
        isPerformingUndoRedo = true
        defer { isPerformingUndoRedo = false }
        return text
    }
}
