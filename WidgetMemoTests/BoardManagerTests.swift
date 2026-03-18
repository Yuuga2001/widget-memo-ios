import Testing
import SwiftUI
@testable import WidgetMemo

struct BoardManagerTests {

    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "test.\(UUID().uuidString)")!
    }

    // MARK: - Init

    @Test func init_creates4Boards() {
        let manager = BoardManager(defaults: makeDefaults())
        #expect(manager.boards.count == 4)
    }

    @Test func init_defaultSelectedIndex() {
        let manager = BoardManager(defaults: makeDefaults())
        #expect(manager.selectedIndex == 0)
    }

    @Test func init_boardsHaveCorrectIndices() {
        let manager = BoardManager(defaults: makeDefaults())
        for i in 0..<4 {
            #expect(manager.boards[i].boardIndex == i)
        }
    }

    // MARK: - Selected Index Persistence

    @Test func selectedIndex_persistence() {
        let defaults = makeDefaults()
        let manager1 = BoardManager(defaults: defaults)
        manager1.selectedIndex = 2

        let manager2 = BoardManager(defaults: defaults)
        #expect(manager2.selectedIndex == 2)
    }

    @Test func selectedIndex_clampsToBounds() {
        let defaults = makeDefaults()
        let manager = BoardManager(defaults: defaults)
        manager.selectedIndex = 10
        #expect(manager.selectedIndex == 3)

        manager.selectedIndex = -1
        #expect(manager.selectedIndex == 0)
    }

    // MARK: - Migration

    @Test func migration_movesLegacyDataToBoard0() {
        let defaults = makeDefaults()

        // 旧キーでデータを保存
        defaults.set("旧メモ", forKey: AppConstants.legacyMemoTextKey)
        defaults.set(24.0, forKey: AppConstants.legacyFontSizeKey)
        MemoStore.saveColor(Color.red, forKey: AppConstants.legacyBackgroundColorKey, in: defaults)
        MemoStore.saveColor(Color.green, forKey: AppConstants.legacyTextColorKey, in: defaults)

        let manager = BoardManager(defaults: defaults)

        #expect(manager.boards[0].text == "旧メモ")
        #expect(manager.boards[0].fontSize == 24.0)

        // Board 1 はデフォルトのまま
        #expect(manager.boards[1].text == AppConstants.defaultText)
    }

    @Test func migration_isIdempotent() {
        let defaults = makeDefaults()

        defaults.set("旧メモ", forKey: AppConstants.legacyMemoTextKey)
        let _ = BoardManager(defaults: defaults)

        // Board 0 のテキストを変更
        defaults.set("新しいメモ", forKey: AppConstants.memoTextKey(for: 0))

        // 再度 BoardManager を作成しても上書きされない
        let manager2 = BoardManager(defaults: defaults)
        #expect(manager2.boards[0].text == "新しいメモ")
    }

    @Test func migration_skipsWhenNoLegacyData() {
        let defaults = makeDefaults()
        let manager = BoardManager(defaults: defaults)

        // デフォルトテキストのまま
        #expect(manager.boards[0].text == AppConstants.defaultText)
        #expect(defaults.bool(forKey: AppConstants.dataMigratedKey) == true)
    }
}
