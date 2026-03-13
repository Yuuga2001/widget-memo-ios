import WidgetKit
import SwiftUI

struct MemoTimelineProvider: TimelineProvider {
    typealias Entry = MemoWidgetEntry

    func placeholder(in context: Context) -> MemoWidgetEntry {
        MemoWidgetEntry(
            date: .now,
            text: "メモを入力...",
            fontSize: AppConstants.defaultFontSize,
            backgroundColor: .yellow,
            textColor: .black
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MemoWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MemoWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    // MARK: - Private

    private func loadEntry() -> MemoWidgetEntry {
        let defaults = UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
        let text = defaults.string(forKey: AppConstants.memoTextKey) ?? ""
        let savedFontSize = defaults.double(forKey: AppConstants.fontSizeKey)
        let fontSize = savedFontSize > 0 ? savedFontSize : AppConstants.defaultFontSize
        let bgColor = MemoStore.loadColor(from: defaults, key: AppConstants.backgroundColorKey) ?? .yellow
        let textColor = MemoStore.loadColor(from: defaults, key: AppConstants.textColorKey) ?? .primary

        return MemoWidgetEntry(
            date: .now,
            text: text,
            fontSize: fontSize,
            backgroundColor: bgColor,
            textColor: textColor
        )
    }
}
