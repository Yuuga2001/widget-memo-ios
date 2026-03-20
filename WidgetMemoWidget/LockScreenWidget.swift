import WidgetKit
import SwiftUI

struct LockScreenWidgetEntryView: View {
    var entry: MemoWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .accessoryRectangular:
                rectangularView
            case .accessoryCircular:
                circularView
            case .accessoryInline:
                inlineView
            default:
                Text(entry.text)
            }
        }
        .widgetURL(URL(string: "memonow://board/\(entry.boardIndex)"))
    }

    private var rectangularView: some View {
        Text(entry.text.isEmpty ? String(localized: "No memo") : entry.text)
            .font(.system(size: 12))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .multilineTextAlignment(.leading)
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text(String(entry.text.prefix(10)))
                .font(.system(size: 10))
                .multilineTextAlignment(.center)
                .padding(4)
        }
    }

    private var inlineView: some View {
        Text(entry.text.isEmpty ? String(localized: "No memo") : entry.text)
    }
}

struct LockScreenWidget: Widget {
    let kind = AppConstants.lockScreenWidgetKind

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectBoardIntent.self, provider: MemoTimelineProvider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MemoNow")
        .description("Display memo on lock screen")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}
