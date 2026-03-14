import Foundation

enum AppConstants {
    static let appGroupID = "group.jp.riverapp.WidgetMemo"
    static let memoTextKey = "memo_text"
    static let fontSizeKey = "font_size"
    static let backgroundColorKey = "background_color"
    static let textColorKey = "text_color"
    static let defaultText = "メモを入力"
    static let defaultFontSize: Double = 18.0
    static let minFontSize: Double = 10.0
    static let maxFontSize: Double = 48.0
    static let widgetKind = "WidgetMemoWidget"
    static let lockScreenWidgetKind = "WidgetMemoLockScreen"

    // MARK: - URLs

    static let aboutURL = URL(string: "https://riverapp.jp/app-document/QuickNote/about")!
    static let privacyPolicyURL = URL(string: "https://riverapp.jp/app-document/QuickNote/privacy-policy")!
    static let contactURL = URL(string: "https://forms.gle/68uVrDj6ACmN9PNu8")!
}
