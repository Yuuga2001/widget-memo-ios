import WidgetKit
import SwiftUI

struct MemoTimelineProvider: AppIntentTimelineProvider {
    typealias Entry = MemoWidgetEntry
    typealias Intent = SelectBoardIntent

    func placeholder(in context: Context) -> MemoWidgetEntry {
        MemoWidgetEntry(
            date: .now,
            text: "メモを入力...",
            fontSize: AppConstants.defaultFontSize,
            backgroundColor: Color(red: 0.0, green: 0.573, blue: 0.890),
            textColor: .white,
            boardIndex: 0
        )
    }

    func snapshot(for configuration: SelectBoardIntent, in context: Context) async -> MemoWidgetEntry {
        loadEntry(boardIndex: configuration.boardIndex)
    }

    func timeline(for configuration: SelectBoardIntent, in context: Context) async -> Timeline<MemoWidgetEntry> {
        let entry = loadEntry(boardIndex: configuration.boardIndex)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    // MARK: - Private

    private func loadEntry(boardIndex: Int) -> MemoWidgetEntry {
        let defaults = UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
        let text = defaults.string(forKey: AppConstants.memoTextKey(for: boardIndex)) ?? ""
        let savedFontSize = defaults.double(forKey: AppConstants.fontSizeKey(for: boardIndex))
        let fontSize = savedFontSize > 0 ? savedFontSize : AppConstants.defaultFontSize

        let colors = AppConstants.defaultBoardColors[boardIndex]
        let bgColor = MemoStore.loadColor(from: defaults, key: AppConstants.backgroundColorKey(for: boardIndex))
            ?? Color(red: colors.bg.r, green: colors.bg.g, blue: colors.bg.b)
        let textColor = MemoStore.loadColor(from: defaults, key: AppConstants.textColorKey(for: boardIndex))
            ?? Color(red: colors.text.r, green: colors.text.g, blue: colors.text.b)

        return MemoWidgetEntry(
            date: .now,
            text: text,
            fontSize: fontSize,
            backgroundColor: bgColor,
            textColor: textColor,
            boardIndex: boardIndex
        )
    }
}
