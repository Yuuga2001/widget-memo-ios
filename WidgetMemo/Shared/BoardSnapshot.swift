import Foundation

/// ボードの状態を保存するスナップショット
struct BoardSnapshot: Codable, Identifiable {
    let id: UUID
    let date: Date
    let text: String
    let fontSize: Double
    let backgroundColor: [Double]  // RGBA
    let textColor: [Double]        // RGBA
    let boardName: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        text: String,
        fontSize: Double,
        backgroundColor: [Double],
        textColor: [Double],
        boardName: String
    ) {
        self.id = id
        self.date = date
        self.text = text
        self.fontSize = fontSize
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.boardName = boardName
    }
}
