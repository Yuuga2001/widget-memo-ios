import Testing
import SwiftUI
@testable import WidgetMemo

struct SnapshotStoreTests {

    private func makeStore(boardIndex: Int = 0) -> (MemoStore, SnapshotStore, UserDefaults) {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let memoStore = MemoStore(boardIndex: boardIndex, defaults: defaults)
        let snapshotStore = SnapshotStore(defaults: defaults)
        return (memoStore, snapshotStore, defaults)
    }

    // MARK: - 初期状態

    @Test func initialState_noSnapshots() {
        let (memoStore, snapshotStore, _) = makeStore()
        let snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(snapshots.isEmpty)
    }

    // MARK: - Save

    @Test func save_createsSnapshot() {
        let (memoStore, snapshotStore, _) = makeStore()
        memoStore.text = "Hello"
        snapshotStore.save(from: memoStore)
        let snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(snapshots.count == 1)
        #expect(snapshots[0].text == "Hello")
    }

    @Test func save_preservesFontSize() {
        let (memoStore, snapshotStore, _) = makeStore()
        memoStore.fontSize = 24.0
        snapshotStore.save(from: memoStore)
        let snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(snapshots[0].fontSize == 24.0)
    }

    @Test func save_preservesBoardName() {
        let (memoStore, snapshotStore, _) = makeStore()
        memoStore.boardName = "MyBoard"
        snapshotStore.save(from: memoStore)
        let snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(snapshots[0].boardName == "MyBoard")
    }

    @Test func save_preservesColors() {
        let (memoStore, snapshotStore, _) = makeStore()
        snapshotStore.save(from: memoStore)
        let snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(snapshots[0].backgroundColor.count == 4)
        #expect(snapshots[0].textColor.count == 4)
    }

    @Test func save_multipleSaves_orderedByDate() {
        let (memoStore, snapshotStore, _) = makeStore()
        memoStore.text = "First"
        snapshotStore.save(from: memoStore)
        memoStore.text = "Second"
        snapshotStore.save(from: memoStore)
        memoStore.text = "Third"
        snapshotStore.save(from: memoStore)

        let snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(snapshots.count == 3)
        // 新しい順
        #expect(snapshots[0].text == "Third")
        #expect(snapshots[1].text == "Second")
        #expect(snapshots[2].text == "First")
    }

    // MARK: - Restore

    @Test func restore_revertsText() {
        let (memoStore, snapshotStore, _) = makeStore()
        memoStore.text = "Original"
        snapshotStore.save(from: memoStore)
        memoStore.text = "Changed"

        let snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        snapshotStore.restore(snapshots[0], to: memoStore)
        #expect(memoStore.text == "Original")
    }

    @Test func restore_revertsFontSize() {
        let (memoStore, snapshotStore, _) = makeStore()
        memoStore.fontSize = 30.0
        snapshotStore.save(from: memoStore)
        memoStore.fontSize = 12.0

        let snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        snapshotStore.restore(snapshots[0], to: memoStore)
        #expect(memoStore.fontSize == 30.0)
    }

    @Test func restore_revertsBoardName() {
        let (memoStore, snapshotStore, _) = makeStore()
        memoStore.boardName = "SavedName"
        snapshotStore.save(from: memoStore)
        memoStore.boardName = "NewName"

        let snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        snapshotStore.restore(snapshots[0], to: memoStore)
        #expect(memoStore.boardName == "SavedName")
    }

    @Test func restore_autoSavesCurrentState() {
        let (memoStore, snapshotStore, _) = makeStore()
        memoStore.text = "V1"
        snapshotStore.save(from: memoStore)
        memoStore.text = "V2"

        let snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        // 復元前は 1 件
        #expect(snapshots.count == 1)

        snapshotStore.restore(snapshots[0], to: memoStore)

        // 復元後は 2 件（自動保存 + 元の1件）
        let after = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(after.count == 2)
        // 最新の自動保存は "V2"
        #expect(after[0].text == "V2")
    }

    // MARK: - Delete

    @Test func delete_removesSnapshot() {
        let (memoStore, snapshotStore, _) = makeStore()
        memoStore.text = "ToDelete"
        snapshotStore.save(from: memoStore)

        var snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(snapshots.count == 1)

        snapshotStore.delete(snapshots[0], for: memoStore.boardIndex)
        snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(snapshots.isEmpty)
    }

    @Test func delete_onlyRemovesSpecified() {
        let (memoStore, snapshotStore, _) = makeStore()
        memoStore.text = "Keep"
        snapshotStore.save(from: memoStore)
        memoStore.text = "Remove"
        snapshotStore.save(from: memoStore)

        var snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(snapshots.count == 2)

        // 最新（"Remove"）を削除
        snapshotStore.delete(snapshots[0], for: memoStore.boardIndex)
        snapshots = snapshotStore.snapshots(for: memoStore.boardIndex)
        #expect(snapshots.count == 1)
        #expect(snapshots[0].text == "Keep")
    }

    // MARK: - ボード独立性

    @Test func snapshots_independentPerBoard() {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        let store0 = MemoStore(boardIndex: 0, defaults: defaults)
        let store1 = MemoStore(boardIndex: 1, defaults: defaults)
        let snapshotStore = SnapshotStore(defaults: defaults)

        store0.text = "Board0"
        snapshotStore.save(from: store0)
        store1.text = "Board1"
        snapshotStore.save(from: store1)

        #expect(snapshotStore.snapshots(for: 0).count == 1)
        #expect(snapshotStore.snapshots(for: 1).count == 1)
        #expect(snapshotStore.snapshots(for: 0)[0].text == "Board0")
        #expect(snapshotStore.snapshots(for: 1)[0].text == "Board1")
    }
}
