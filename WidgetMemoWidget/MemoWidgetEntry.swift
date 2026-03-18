import WidgetKit
import SwiftUI

struct MemoWidgetEntry: TimelineEntry {
    let date: Date
    let text: String
    let fontSize: Double
    let backgroundColor: Color
    let textColor: Color
    let boardIndex: Int
}
