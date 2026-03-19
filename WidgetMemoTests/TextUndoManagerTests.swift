import Testing
@testable import WidgetMemo

struct TextUndoManagerTests {

    // MARK: - 初期状態

    @Test func initialState_cannotUndo() {
        var manager = TextUndoManager()
        manager.initialize(with: "Hello")
        #expect(!manager.canUndo)
    }

    @Test func initialState_cannotRedo() {
        var manager = TextUndoManager()
        manager.initialize(with: "Hello")
        #expect(!manager.canRedo)
    }

    // MARK: - initialize

    @Test func initialize_setsInitialText() {
        var manager = TextUndoManager()
        manager.initialize(with: "ABC")
        // Undo で初期テキストに戻れることを確認
        manager.textDidChange("DEF")
        let result = manager.undo()
        #expect(result == "ABC")
    }

    @Test func initialize_calledTwice_doesNotReset() {
        var manager = TextUndoManager()
        manager.initialize(with: "First")
        manager.textDidChange("Second")
        manager.initialize(with: "Ignored")
        // 2回目の initialize は無視される
        let result = manager.undo()
        #expect(result == "First")
    }

    // MARK: - textDidChange

    @Test func textDidChange_enablesUndo() {
        var manager = TextUndoManager()
        manager.initialize(with: "")
        manager.textDidChange("A")
        #expect(manager.canUndo)
    }

    @Test func textDidChange_sameText_ignored() {
        var manager = TextUndoManager()
        manager.initialize(with: "Hello")
        manager.textDidChange("Hello")
        #expect(!manager.canUndo)
    }

    @Test func textDidChange_clearsRedoStack() {
        var manager = TextUndoManager()
        manager.initialize(with: "A")
        manager.textDidChange("B")
        _ = manager.undo()
        #expect(manager.canRedo)
        manager.textDidChange("C")
        #expect(!manager.canRedo)
    }

    // MARK: - Undo

    @Test func undo_returnsPrexiousText() {
        var manager = TextUndoManager()
        manager.initialize(with: "A")
        manager.textDidChange("B")
        manager.textDidChange("C")
        #expect(manager.undo() == "B")
        #expect(manager.undo() == "A")
    }

    @Test func undo_whenEmpty_returnsNil() {
        var manager = TextUndoManager()
        manager.initialize(with: "A")
        #expect(manager.undo() == nil)
    }

    @Test func undo_enablesRedo() {
        var manager = TextUndoManager()
        manager.initialize(with: "A")
        manager.textDidChange("B")
        _ = manager.undo()
        #expect(manager.canRedo)
    }

    // MARK: - Redo

    @Test func redo_restoresUndoneText() {
        var manager = TextUndoManager()
        manager.initialize(with: "A")
        manager.textDidChange("B")
        _ = manager.undo()
        #expect(manager.redo() == "B")
    }

    @Test func redo_whenEmpty_returnsNil() {
        var manager = TextUndoManager()
        manager.initialize(with: "A")
        #expect(manager.redo() == nil)
    }

    @Test func redo_afterRedo_canUndoAgain() {
        var manager = TextUndoManager()
        manager.initialize(with: "A")
        manager.textDidChange("B")
        _ = manager.undo()
        _ = manager.redo()
        #expect(manager.canUndo)
        #expect(manager.undo() == "A")
    }

    // MARK: - 複合シナリオ

    @Test func multipleUndoRedo_roundTrip() {
        var manager = TextUndoManager()
        manager.initialize(with: "A")
        manager.textDidChange("B")
        manager.textDidChange("C")
        manager.textDidChange("D")

        // D → C → B → A
        #expect(manager.undo() == "C")
        #expect(manager.undo() == "B")
        #expect(manager.undo() == "A")
        #expect(!manager.canUndo)

        // A → B → C → D
        #expect(manager.redo() == "B")
        #expect(manager.redo() == "C")
        #expect(manager.redo() == "D")
        #expect(!manager.canRedo)
    }

    @Test func undoThenNewEdit_clearsRedoHistory() {
        var manager = TextUndoManager()
        manager.initialize(with: "A")
        manager.textDidChange("B")
        manager.textDidChange("C")
        _ = manager.undo() // C → B
        manager.textDidChange("X")
        // Redo は不可（新しい編集で分岐）
        #expect(!manager.canRedo)
        // Undo で B に戻れる
        #expect(manager.undo() == "B")
    }

    @Test func emptyStringHandling() {
        var manager = TextUndoManager()
        manager.initialize(with: "")
        manager.textDidChange("Hello")
        manager.textDidChange("")
        #expect(manager.undo() == "Hello")
        #expect(manager.undo() == "")
        #expect(!manager.canUndo)
    }
}
