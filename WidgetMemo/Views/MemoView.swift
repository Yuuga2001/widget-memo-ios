import SwiftUI

struct MemoView: View {
    @Environment(MemoStore.self) private var store
    @Environment(BoardManager.self) private var manager
    @State private var showSettings = false
    @State private var showHelp = false
    @State private var showSnapshots = false
    @State private var snapshotStore = SnapshotStore()
    @State private var isEditingName = false
    @State private var canUndo = false
    @State private var canRedo = false
    @State private var textUndoManager = TextUndoManager()
    @State private var showCopiedToast = false
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

                if showCopiedToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Copied to clipboard")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(.black.opacity(0.75))
                        )
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .allowsHitTesting(false)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 12) {
                        Button {
                            showSnapshots = true
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityIdentifier("snapshotButton")

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
                        TextField("Board Name", text: $store.boardName)
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
                    HStack(spacing: 12) {
                        Button {
                            UIPasteboard.general.string = store.text
                            withAnimation(.spring(response: 0.3)) {
                                showCopiedToast = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showCopiedToast = false
                                }
                            }
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityIdentifier("copyButton")

                        Button {
                            showHelp = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityIdentifier("helpButton")

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 17, weight: .light))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                SettingsSheet()
                    .environment(store)
                    .environment(manager)
            }
            .sheet(isPresented: $showHelp) {
                HelpGuideView()
                    .presentationDetents([.medium, .large])
            }
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showSnapshots) {
            SnapshotSheetView(
                store: store,
                snapshotStore: snapshotStore
            )
            .presentationDetents([.medium, .large])
        }
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
