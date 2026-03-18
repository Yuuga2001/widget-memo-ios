import Foundation

enum AppConstants {
    static let appGroupID = "group.jp.riverapp.WidgetMemo"
    static let defaultText = "メモを入力"
    static let defaultFontSize: Double = 18.0
    static let minFontSize: Double = 10.0
    static let maxFontSize: Double = 48.0
    static let widgetKind = "WidgetMemoWidget"
    static let lockScreenWidgetKind = "WidgetMemoLockScreen"

    // MARK: - Board

    static let boardCount = 4
    static let selectedBoardIndexKey = "selected_board_index"
    static let dataMigratedKey = "data_migrated_v2"
    static let defaultBoardNames = ["1", "2", "3", "4"]

    /// (背景RGB, 文字RGB) のタプル配列
    static let defaultBoardColors: [(bg: (r: Double, g: Double, b: Double), text: (r: Double, g: Double, b: Double))] = [
        (bg: (0.0, 0.573, 0.890), text: (1.0, 1.0, 1.0)),   // 青 + 白
        (bg: (0.298, 0.686, 0.314), text: (1.0, 1.0, 1.0)),  // 緑 + 白
        (bg: (0.898, 0.224, 0.208), text: (1.0, 1.0, 1.0)),  // 赤 + 白
        (bg: (1.0, 1.0, 1.0), text: (0.0, 0.0, 0.0)),        // 白 + 黒
    ]

    // MARK: - Board Keys

    static func memoTextKey(for board: Int) -> String { "board_\(board)_memo_text" }
    static func fontSizeKey(for board: Int) -> String { "board_\(board)_font_size" }
    static func backgroundColorKey(for board: Int) -> String { "board_\(board)_background_color" }
    static func textColorKey(for board: Int) -> String { "board_\(board)_text_color" }
    static func boardNameKey(for board: Int) -> String { "board_\(board)_name" }

    // MARK: - Legacy Keys (for migration)

    static let legacyMemoTextKey = "memo_text"
    static let legacyFontSizeKey = "font_size"
    static let legacyBackgroundColorKey = "background_color"
    static let legacyTextColorKey = "text_color"

    // MARK: - WatchConnectivity

    static let watchContextBoardsKey = "boards"
    static let watchContextTimestampKey = "timestamp"

    // MARK: - Watch Font Size

    static let watchDefaultFontSize: Double = 14.0
    static let watchMinFontSize: Double = 10.0
    static let watchMaxFontSize: Double = 30.0

    // MARK: - URLs

    static let aboutURL = URL(string: "https://riverapp.jp/app-document/MemoNow/about")!
    static let privacyPolicyURL = URL(string: "https://riverapp.jp/app-document/MemoNow/privacy-policy")!
    static let contactURL = URL(string: "https://riverapp.jp/app-document/MemoNow/contact")!
}
