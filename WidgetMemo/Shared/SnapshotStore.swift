import SwiftUI

/// ボードスナップショットの保存・読込・復元を管理する
@Observable
final class SnapshotStore {

    private let defaults: UserDefaults

    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults ?? UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
    }

    // MARK: - Read

    /// 指定ボードのスナップショット一覧を新しい順で返す
    func snapshots(for boardIndex: Int) -> [BoardSnapshot] {
        loadSnapshots(for: boardIndex)
    }

    // MARK: - Save

    /// MemoStore の現在状態をスナップショットとして保存
    func save(from store: MemoStore) {
        let snapshot = BoardSnapshot(
            text: store.text,
            fontSize: store.fontSize,
            backgroundColor: colorToArray(store.backgroundColor),
            textColor: colorToArray(store.textColor),
            boardName: store.boardName
        )
        var list = loadSnapshots(for: store.boardIndex)
        list.insert(snapshot, at: 0)
        saveSnapshots(list, for: store.boardIndex)
    }

    // MARK: - Restore

    /// スナップショットを復元する（復元前に現在状態を自動保存）
    func restore(_ snapshot: BoardSnapshot, to store: MemoStore) {
        // 復元前に現在状態を保存
        save(from: store)

        // ボードに上書き
        store.text = snapshot.text
        store.fontSize = snapshot.fontSize
        store.boardName = snapshot.boardName
        if snapshot.backgroundColor.count == 4 {
            store.backgroundColor = Color(
                red: snapshot.backgroundColor[0],
                green: snapshot.backgroundColor[1],
                blue: snapshot.backgroundColor[2],
                opacity: snapshot.backgroundColor[3]
            )
        }
        if snapshot.textColor.count == 4 {
            store.textColor = Color(
                red: snapshot.textColor[0],
                green: snapshot.textColor[1],
                blue: snapshot.textColor[2],
                opacity: snapshot.textColor[3]
            )
        }
    }

    // MARK: - Delete

    /// 個別スナップショットを削除
    func delete(_ snapshot: BoardSnapshot, for boardIndex: Int) {
        var list = loadSnapshots(for: boardIndex)
        list.removeAll { $0.id == snapshot.id }
        saveSnapshots(list, for: boardIndex)
    }

    // MARK: - Private

    private func loadSnapshots(for boardIndex: Int) -> [BoardSnapshot] {
        guard let data = defaults.data(forKey: AppConstants.snapshotKey(for: boardIndex)),
              let list = try? JSONDecoder().decode([BoardSnapshot].self, from: data) else {
            return []
        }
        // 新しい順にソート
        return list.sorted { $0.date > $1.date }
    }

    private func saveSnapshots(_ snapshots: [BoardSnapshot], for boardIndex: Int) {
        guard let data = try? JSONEncoder().encode(snapshots) else { return }
        defaults.set(data, forKey: AppConstants.snapshotKey(for: boardIndex))
    }

    private func colorToArray(_ color: Color) -> [Double] {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return [Double(r), Double(g), Double(b), Double(a)]
    }
}
