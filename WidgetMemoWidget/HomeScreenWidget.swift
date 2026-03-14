import WidgetKit
import SwiftUI

struct HomeScreenWidgetEntryView: View {
    var entry: MemoWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Text(entry.text.isEmpty ? "メモなし" : entry.text)
            .font(.system(size: adjustedFontSize))
            .foregroundStyle(entry.textColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .multilineTextAlignment(.leading)
            .containerBackground(for: .widget) {
                ZStack {
                    Color.white
                    LinearGradient(
                        colors: [
                            entry.backgroundColor,
                            entry.backgroundColor.opacity(0.4),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
    }

    private var adjustedFontSize: Double {
        switch family {
        case .systemSmall:
            return min(entry.fontSize, 20)
        case .systemMedium:
            return min(entry.fontSize, 28)
        default:
            return entry.fontSize
        }
    }
}

struct HomeScreenWidget: Widget {
    let kind = AppConstants.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MemoTimelineProvider()) { entry in
            HomeScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WidgetMemo")
        .description("メモの内容を表示します")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
