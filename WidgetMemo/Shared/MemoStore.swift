import SwiftUI
import WidgetKit

@Observable
final class MemoStore {

    // MARK: - Board Identity

    let boardIndex: Int

    var boardName: String {
        didSet {
            defaults.set(boardName, forKey: AppConstants.boardNameKey(for: boardIndex))
        }
    }

    // MARK: - Published State

    var text: String {
        didSet {
            defaults.set(text, forKey: AppConstants.memoTextKey(for: boardIndex))
            scheduleWidgetReload()
        }
    }

    var fontSize: Double {
        didSet {
            defaults.set(fontSize, forKey: AppConstants.fontSizeKey(for: boardIndex))
            scheduleWidgetReload()
        }
    }

    var backgroundColor: Color {
        didSet {
            Self.saveColor(backgroundColor, forKey: AppConstants.backgroundColorKey(for: boardIndex), in: defaults)
            scheduleWidgetReload()
        }
    }

    var textColor: Color {
        didSet {
            Self.saveColor(textColor, forKey: AppConstants.textColorKey(for: boardIndex), in: defaults)
            scheduleWidgetReload()
        }
    }

    // MARK: - Defaults

    var defaultBackgroundColor: Color {
        let colors = AppConstants.defaultBoardColors[boardIndex]
        return Color(red: colors.bg.r, green: colors.bg.g, blue: colors.bg.b)
    }

    var defaultTextColor: Color {
        let colors = AppConstants.defaultBoardColors[boardIndex]
        return Color(red: colors.text.r, green: colors.text.g, blue: colors.text.b)
    }

    // MARK: - Private

    private let defaults: UserDefaults
    private var reloadTask: DispatchWorkItem?

    // MARK: - Init

    init(boardIndex: Int = 0, defaults: UserDefaults? = nil) {
        let ud = defaults ?? UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
        self.defaults = ud
        self.boardIndex = boardIndex

        let colors = AppConstants.defaultBoardColors[boardIndex]
        let defaultBg = Color(red: colors.bg.r, green: colors.bg.g, blue: colors.bg.b)
        let defaultText = Color(red: colors.text.r, green: colors.text.g, blue: colors.text.b)

        let savedFontSize = ud.double(forKey: AppConstants.fontSizeKey(for: boardIndex))
        self.text = ud.string(forKey: AppConstants.memoTextKey(for: boardIndex)) ?? AppConstants.defaultText
        self.fontSize = savedFontSize > 0 ? savedFontSize : AppConstants.defaultFontSize
        self.backgroundColor = Self.loadColor(from: ud, key: AppConstants.backgroundColorKey(for: boardIndex)) ?? defaultBg
        self.textColor = Self.loadColor(from: ud, key: AppConstants.textColorKey(for: boardIndex)) ?? defaultText
        self.boardName = ud.string(forKey: AppConstants.boardNameKey(for: boardIndex)) ?? AppConstants.defaultBoardNames[boardIndex]
    }

    // MARK: - Reset & Delete

    /// フォントサイズ・背景色・文字色をデフォルトに戻す（メモ内容は保持）
    func resetToDefaults() {
        fontSize = AppConstants.defaultFontSize
        backgroundColor = defaultBackgroundColor
        textColor = defaultTextColor
        reloadWidgetsNow()
    }

    /// すべてのデータを初期化する
    func deleteAllData() {
        text = AppConstants.defaultText
        fontSize = AppConstants.defaultFontSize
        backgroundColor = defaultBackgroundColor
        textColor = defaultTextColor
        reloadWidgetsNow()
    }

    // MARK: - Widget Reload

    func reloadWidgetsNow() {
        reloadTask?.cancel()
        reloadTask = nil
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func scheduleWidgetReload() {
        reloadTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            guard self != nil else { return }
            WidgetCenter.shared.reloadAllTimelines()
        }
        reloadTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: task)
    }

    // MARK: - Color Persistence

    static func saveColor(_ color: Color, forKey key: String, in defaults: UserDefaults) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        defaults.set([Double(r), Double(g), Double(b), Double(a)], forKey: key)
    }

    static func loadColor(from defaults: UserDefaults, key: String) -> Color? {
        guard let components = defaults.array(forKey: key) as? [Double],
              components.count == 4 else {
            return nil
        }
        return Color(
            red: components[0],
            green: components[1],
            blue: components[2],
            opacity: components[3]
        )
    }
}
