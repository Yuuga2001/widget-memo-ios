import Testing
import SwiftUI
@testable import WidgetMemo

struct WatchConnectivityServiceTests {

    private func makeStore(boardIndex: Int = 0) -> MemoStore {
        let defaults = UserDefaults(suiteName: "test.\(UUID().uuidString)")!
        return MemoStore(boardIndex: boardIndex, defaults: defaults)
    }

    // MARK: - Encode / Decode Round Trip

    @Test func encodeDecode_roundTrip_singleBoard() {
        let store = makeStore(boardIndex: 0)
        store.text = "テストメモ"
        store.fontSize = 24.0
        store.boardName = "マイボード"

        let service = WatchConnectivityService.shared
        let context = service.encodeBoardsContext([store])
        let decoded = service.decodeBoardsFromContext(context)

        #expect(decoded != nil)
        #expect(decoded?.count == 1)

        if let board = decoded?.first {
            #expect(board.index == 0)
            #expect(board.text == "テストメモ")
            #expect(board.fontSize == 24.0)
            #expect(board.boardName == "マイボード")
            #expect(board.backgroundColor.count == 4)
            #expect(board.textColor.count == 4)
        }
    }

    @Test func encodeDecode_roundTrip_allBoards() {
        let suiteName = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let boards = (0..<4).map { MemoStore(boardIndex: $0, defaults: defaults) }

        boards[0].text = "ボード1"
        boards[1].text = "ボード2"
        boards[2].text = "ボード3"
        boards[3].text = "ボード4"

        let service = WatchConnectivityService.shared
        let context = service.encodeBoardsContext(boards)
        let decoded = service.decodeBoardsFromContext(context)

        #expect(decoded?.count == 4)
        #expect(decoded?[0].text == "ボード1")
        #expect(decoded?[1].text == "ボード2")
        #expect(decoded?[2].text == "ボード3")
        #expect(decoded?[3].text == "ボード4")
    }

    @Test func encodeDecode_preservesBoardIndices() {
        let suiteName = "test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let boards = (0..<4).map { MemoStore(boardIndex: $0, defaults: defaults) }

        let service = WatchConnectivityService.shared
        let context = service.encodeBoardsContext(boards)
        let decoded = service.decodeBoardsFromContext(context)

        for i in 0..<4 {
            #expect(decoded?[i].index == i)
        }
    }

    @Test func encodeDecode_colorPreservation() {
        let store = makeStore(boardIndex: 0)
        store.backgroundColor = Color(red: 0.5, green: 0.3, blue: 0.8, opacity: 1.0)
        store.textColor = Color(red: 0.1, green: 0.9, blue: 0.4, opacity: 1.0)

        let service = WatchConnectivityService.shared
        let context = service.encodeBoardsContext([store])
        let decoded = service.decodeBoardsFromContext(context)

        if let board = decoded?.first {
            #expect(abs(board.backgroundColor[0] - 0.5) < 0.01)
            #expect(abs(board.backgroundColor[1] - 0.3) < 0.01)
            #expect(abs(board.backgroundColor[2] - 0.8) < 0.01)
            #expect(abs(board.textColor[0] - 0.1) < 0.01)
            #expect(abs(board.textColor[1] - 0.9) < 0.01)
            #expect(abs(board.textColor[2] - 0.4) < 0.01)
        }
    }

    // MARK: - Context Structure

    @Test func encode_containsTimestamp() {
        let store = makeStore()
        let service = WatchConnectivityService.shared
        let context = service.encodeBoardsContext([store])

        let timestamp = context[AppConstants.watchContextTimestampKey] as? Double
        #expect(timestamp != nil)
        #expect(timestamp! > 0)
    }

    @Test func encode_containsBoardsKey() {
        let store = makeStore()
        let service = WatchConnectivityService.shared
        let context = service.encodeBoardsContext([store])

        let boards = context[AppConstants.watchContextBoardsKey] as? [[String: Any]]
        #expect(boards != nil)
        #expect(boards?.count == 1)
    }

    // MARK: - Decode Edge Cases

    @Test func decode_returnsNilForEmptyContext() {
        let service = WatchConnectivityService.shared
        let decoded = service.decodeBoardsFromContext([:])
        #expect(decoded == nil)
    }

    @Test func decode_returnsNilForInvalidBoardsData() {
        let service = WatchConnectivityService.shared
        let decoded = service.decodeBoardsFromContext([AppConstants.watchContextBoardsKey: "invalid"])
        #expect(decoded == nil)
    }

    @Test func decode_skipsIncompleteBoardData() {
        let service = WatchConnectivityService.shared
        let incompleteBoardData: [[String: Any]] = [
            ["index": 0, "text": "test"]  // Missing fields
        ]
        let context: [String: Any] = [AppConstants.watchContextBoardsKey: incompleteBoardData]
        let decoded = service.decodeBoardsFromContext(context)

        #expect(decoded != nil)
        #expect(decoded?.count == 0)  // Incomplete board is skipped
    }

    @Test func decode_skipsInvalidColorArraySize() {
        let service = WatchConnectivityService.shared
        let boardData: [[String: Any]] = [
            [
                "index": 0,
                "text": "test",
                "fontSize": 18.0,
                "backgroundColor": [1.0, 0.0],  // Only 2 elements (need 4)
                "textColor": [1.0, 1.0, 1.0, 1.0],
                "boardName": "1"
            ]
        ]
        let context: [String: Any] = [AppConstants.watchContextBoardsKey: boardData]
        let decoded = service.decodeBoardsFromContext(context)

        #expect(decoded?.count == 0)  // Invalid color array causes skip
    }

    // MARK: - Special Characters

    @Test func encodeDecode_specialCharacters() {
        let store = makeStore()
        store.text = "🎉 テスト\n改行\tタブ"
        store.boardName = "📝メモ"

        let service = WatchConnectivityService.shared
        let context = service.encodeBoardsContext([store])
        let decoded = service.decodeBoardsFromContext(context)

        #expect(decoded?.first?.text == "🎉 テスト\n改行\tタブ")
        #expect(decoded?.first?.boardName == "📝メモ")
    }

    @Test func encodeDecode_emptyText() {
        let store = makeStore()
        store.text = ""

        let service = WatchConnectivityService.shared
        let context = service.encodeBoardsContext([store])
        let decoded = service.decodeBoardsFromContext(context)

        #expect(decoded?.first?.text == "")
    }
}
