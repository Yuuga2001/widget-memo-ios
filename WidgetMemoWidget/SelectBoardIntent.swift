import AppIntents
import WidgetKit
import SwiftUI

struct BoardEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Board")
    static var defaultQuery = BoardQuery()

    var id: Int
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(id: Int, name: String? = nil) {
        self.id = id
        let defaults = UserDefaults(suiteName: AppConstants.appGroupID) ?? .standard
        self.name = name ?? defaults.string(forKey: AppConstants.boardNameKey(for: id))
            ?? AppConstants.defaultBoardNames[id]
    }
}

struct BoardQuery: EntityQuery {
    func entities(for identifiers: [Int]) async throws -> [BoardEntity] {
        identifiers.compactMap { id in
            guard (0..<AppConstants.boardCount).contains(id) else { return nil }
            return BoardEntity(id: id)
        }
    }

    func suggestedEntities() async throws -> [BoardEntity] {
        (0..<AppConstants.boardCount).map { BoardEntity(id: $0) }
    }

    func defaultResult() async -> BoardEntity? {
        BoardEntity(id: 0)
    }
}

struct SelectBoardIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Board"
    static var description = IntentDescription("Select a board to display")

    @Parameter(title: "Board")
    var board: BoardEntity?

    var boardIndex: Int { board?.id ?? 0 }
}
