import Foundation
import SwiftUI
import WatchConnectivity

/// iPhone ⇔ Watch 間のデータ同期サービス（一方向: iPhone → Watch）
final class WatchConnectivityService: NSObject, WCSessionDelegate {

    static let shared = WatchConnectivityService()

    /// Watch 側でコンテキスト受信時に呼ばれるコールバック
    var onContextReceived: (([String: Any]) -> Void)?

    private override init() {
        super.init()
    }

    // MARK: - Activation

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - iPhone → Watch

    #if os(iOS)
    /// 全ボードデータを Watch に push
    func pushAllBoards(_ boards: [MemoStore]) {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isPaired,
              WCSession.default.isWatchAppInstalled else { return }
        let context = encodeBoardsContext(boards)
        try? WCSession.default.updateApplicationContext(context)
    }
    #endif

    // MARK: - Encode / Decode

    func encodeBoardsContext(_ boards: [MemoStore]) -> [String: Any] {
        let boardsData: [[String: Any]] = boards.map { store in
            var bgComponents: [Double] = [0, 0, 0, 1]
            var textComponents: [Double] = [1, 1, 1, 1]

            #if canImport(UIKit)
            let bgUI = UIColor(store.backgroundColor)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            bgUI.getRed(&r, green: &g, blue: &b, alpha: &a)
            bgComponents = [Double(r), Double(g), Double(b), Double(a)]

            let textUI = UIColor(store.textColor)
            textUI.getRed(&r, green: &g, blue: &b, alpha: &a)
            textComponents = [Double(r), Double(g), Double(b), Double(a)]
            #endif

            return [
                "index": store.boardIndex,
                "text": store.text,
                "fontSize": store.fontSize,
                "backgroundColor": bgComponents,
                "textColor": textComponents,
                "boardName": store.boardName
            ]
        }

        return [
            AppConstants.watchContextBoardsKey: boardsData,
            AppConstants.watchContextTimestampKey: Date().timeIntervalSince1970
        ]
    }

    func decodeBoardsFromContext(_ context: [String: Any]) -> [BoardData]? {
        guard let boardsArray = context[AppConstants.watchContextBoardsKey] as? [[String: Any]] else {
            return nil
        }

        return boardsArray.compactMap { dict in
            guard let index = dict["index"] as? Int,
                  let text = dict["text"] as? String,
                  let fontSize = dict["fontSize"] as? Double,
                  let bgColor = dict["backgroundColor"] as? [Double],
                  let textColor = dict["textColor"] as? [Double],
                  let boardName = dict["boardName"] as? String,
                  bgColor.count == 4,
                  textColor.count == 4 else {
                return nil
            }

            return BoardData(
                index: index,
                text: text,
                fontSize: fontSize,
                backgroundColor: bgColor,
                textColor: textColor,
                boardName: boardName
            )
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Activation complete
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.onContextReceived?(applicationContext)
        }
    }
}

// MARK: - BoardData

struct BoardData {
    let index: Int
    let text: String
    let fontSize: Double
    let backgroundColor: [Double]  // RGBA
    let textColor: [Double]        // RGBA
    let boardName: String
}
