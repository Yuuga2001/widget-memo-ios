import SwiftUI
import WidgetKit

@Observable
final class MemoStore {

    // MARK: - Published State

    var text: String {
        didSet {
            defaults.set(text, forKey: AppConstants.memoTextKey)
            scheduleWidgetReload()
        }
    }

    var fontSize: Double {
        didSet {
            defaults.set(fontSize, forKey: AppConstants.fontSizeKey)
            scheduleWidgetReload()
        }
    }

    var backgroundColor: Color {
        didSet {
            Self.saveColor(backgroundColor, forKey: AppConstants.backgroundColorKey, in: defaults)
            scheduleWidgetReload()
        }
    }

    var textColor: Color {
        didSet {
            Self.saveColor(textColor, forKey: AppConstants.textColorKey, in: defaults)
            scheduleWidgetReload()
        }
    }

    // MARK: - Defaults

    static let defaultBackgroundColor = Color(red: 0.0, green: 0.573, blue: 0.890)
    static let defaultTextColor = Color.white

    // MARK: - Private

    private let defaults: UserDefaults
    private var reloadTask: DispatchWorkItem?

    // MARK: - Init

    init(defaults: UserDefaults? = nil) {
        let ud = defaults ?? UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
        self.defaults = ud

        let savedFontSize = ud.double(forKey: AppConstants.fontSizeKey)
        self.text = ud.string(forKey: AppConstants.memoTextKey) ?? AppConstants.defaultText
        self.fontSize = savedFontSize > 0 ? savedFontSize : AppConstants.defaultFontSize
        self.backgroundColor = Self.loadColor(from: ud, key: AppConstants.backgroundColorKey) ?? Self.defaultBackgroundColor
        self.textColor = Self.loadColor(from: ud, key: AppConstants.textColorKey) ?? Self.defaultTextColor
    }

    // MARK: - Reset & Delete

    /// フォントサイズ・背景色・文字色をデフォルトに戻す（メモ内容は保持）
    func resetToDefaults() {
        fontSize = AppConstants.defaultFontSize
        backgroundColor = Self.defaultBackgroundColor
        textColor = Self.defaultTextColor
        reloadWidgetsNow()
    }

    /// すべてのデータを初期化する
    func deleteAllData() {
        text = AppConstants.defaultText
        fontSize = AppConstants.defaultFontSize
        backgroundColor = Self.defaultBackgroundColor
        textColor = Self.defaultTextColor
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
