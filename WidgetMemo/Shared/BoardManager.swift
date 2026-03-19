import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

@Observable
final class BoardManager {

    let boards: [MemoStore]

    var selectedIndex: Int {
        didSet {
            let clamped = min(max(selectedIndex, 0), AppConstants.boardCount - 1)
            if clamped != selectedIndex { selectedIndex = clamped }
            defaults.set(selectedIndex, forKey: AppConstants.selectedBoardIndexKey)
        }
    }

    private let defaults: UserDefaults

    // MARK: - Init

    init(defaults: UserDefaults? = nil) {
        let ud = defaults ?? UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
        self.defaults = ud

        Self.migrateIfNeeded(defaults: ud)

        self.boards = (0..<AppConstants.boardCount).map { MemoStore(boardIndex: $0, defaults: ud) }

        let saved = ud.integer(forKey: AppConstants.selectedBoardIndexKey)
        self.selectedIndex = min(max(saved, 0), AppConstants.boardCount - 1)
    }

    // MARK: - Migration

    static func migrateIfNeeded(defaults: UserDefaults) {
        guard !defaults.bool(forKey: AppConstants.dataMigratedKey) else { return }

        // 旧キーにデータがあれば Board 0 に移行
        if let legacyText = defaults.string(forKey: AppConstants.legacyMemoTextKey) {
            defaults.set(legacyText, forKey: AppConstants.memoTextKey(for: 0))
        }

        let legacyFontSize = defaults.double(forKey: AppConstants.legacyFontSizeKey)
        if legacyFontSize > 0 {
            defaults.set(legacyFontSize, forKey: AppConstants.fontSizeKey(for: 0))
        }

        if let legacyBg = defaults.array(forKey: AppConstants.legacyBackgroundColorKey) as? [Double], legacyBg.count == 4 {
            defaults.set(legacyBg, forKey: AppConstants.backgroundColorKey(for: 0))
        }

        if let legacyText = defaults.array(forKey: AppConstants.legacyTextColorKey) as? [Double], legacyText.count == 4 {
            defaults.set(legacyText, forKey: AppConstants.textColorKey(for: 0))
        }

        defaults.set(true, forKey: AppConstants.dataMigratedKey)
    }

    // MARK: - Delete All

    /// 全ボードのデータを初期化し、選択インデックスもリセットする
    func deleteAllData() {
        for board in boards {
            board.deleteAllData()
            board.boardName = AppConstants.defaultBoardNames[board.boardIndex]
        }
        // バックアップも全削除
        for i in 0..<AppConstants.boardCount {
            defaults.removeObject(forKey: AppConstants.snapshotKey(for: i))
        }
        selectedIndex = 0
        reloadAllWidgets()
    }

    // MARK: - Widget

    func reloadAllWidgets() {
        #if os(iOS)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
