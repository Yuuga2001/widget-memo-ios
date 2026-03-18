import XCTest

final class UndoRedoUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }

    // MARK: - ボタン存在確認

    func testUndoButtonExists() throws {
        let undoButton = app.buttons["undoButton"]
        XCTAssertTrue(undoButton.waitForExistence(timeout: 5), "Undo ボタンが表示されるべき")
    }

    func testRedoButtonExists() throws {
        let redoButton = app.buttons["redoButton"]
        XCTAssertTrue(redoButton.waitForExistence(timeout: 5), "Redo ボタンが表示されるべき")
    }

    // MARK: - 初期状態

    func testUndoButtonDisabledOnLaunch() throws {
        let undoButton = app.buttons["undoButton"]
        XCTAssertTrue(undoButton.waitForExistence(timeout: 5))
        XCTAssertFalse(undoButton.isEnabled, "起動直後は Undo が無効であるべき")
    }

    func testRedoButtonDisabledOnLaunch() throws {
        let redoButton = app.buttons["redoButton"]
        XCTAssertTrue(redoButton.waitForExistence(timeout: 5))
        XCTAssertFalse(redoButton.isEnabled, "起動直後は Redo が無効であるべき")
    }

    // MARK: - Undo 動作

    func testUndoButtonEnabledAfterTyping() throws {
        let textEditor = app.textViews.firstMatch
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5))
        textEditor.tap()
        textEditor.typeText("Hello")

        let undoButton = app.buttons["undoButton"]
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: undoButton)
        let result = XCTWaiter.wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed, "テキスト入力後は Undo が有効であるべき")
    }

    func testUndoRevertsText() throws {
        let textEditor = app.textViews.firstMatch
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5))
        textEditor.tap()

        // Undo 前のテキストを記録
        let textBefore = textEditor.value as? String ?? ""

        // テキスト入力
        textEditor.typeText("UNDOTEST")

        // テキストが変化したことを確認
        let changed = NSPredicate(format: "value != %@", textBefore)
        let typedExp = XCTNSPredicateExpectation(predicate: changed, object: textEditor)
        XCTAssertEqual(XCTWaiter.wait(for: [typedExp], timeout: 5), .completed, "テキストが入力されるべき")

        let textAfterTyping = textEditor.value as? String ?? ""

        // Undo を実行（1文字分でも戻ればOK）
        let undoButton = app.buttons["undoButton"]
        let enabledPred = NSPredicate(format: "isEnabled == true")
        let enabledExp = XCTNSPredicateExpectation(predicate: enabledPred, object: undoButton)
        XCTAssertEqual(XCTWaiter.wait(for: [enabledExp], timeout: 5), .completed)
        undoButton.tap()

        // Undo 後、テキストが入力後の状態から変化している
        let undone = NSPredicate(format: "value != %@", textAfterTyping)
        let undoneExp = XCTNSPredicateExpectation(predicate: undone, object: textEditor)
        let undoResult = XCTWaiter.wait(for: [undoneExp], timeout: 5)
        XCTAssertEqual(undoResult, .completed, "Undo でテキストが戻るべき")
    }

    // MARK: - Redo 動作

    func testRedoButtonEnabledAfterUndo() throws {
        let textEditor = app.textViews.firstMatch
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5))
        textEditor.tap()
        textEditor.typeText("XYZ")

        let undoButton = app.buttons["undoButton"]
        let enabledPred = NSPredicate(format: "isEnabled == true")
        let enabledExp = XCTNSPredicateExpectation(predicate: enabledPred, object: undoButton)
        XCTAssertEqual(XCTWaiter.wait(for: [enabledExp], timeout: 5), .completed)
        undoButton.tap()

        let redoButton = app.buttons["redoButton"]
        let redoEnabled = XCTNSPredicateExpectation(predicate: enabledPred, object: redoButton)
        let result = XCTWaiter.wait(for: [redoEnabled], timeout: 5)
        XCTAssertEqual(result, .completed, "Undo 後は Redo が有効であるべき")
    }

    func testRedoRestoresText() throws {
        let textEditor = app.textViews.firstMatch
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5))
        textEditor.tap()

        let testText = "REDOTEST"
        textEditor.typeText(testText)

        // テキスト入力確認
        let containsText = NSPredicate(format: "value CONTAINS %@", testText)
        let typed = XCTNSPredicateExpectation(predicate: containsText, object: textEditor)
        XCTAssertEqual(XCTWaiter.wait(for: [typed], timeout: 5), .completed)

        // Undo
        let undoButton = app.buttons["undoButton"]
        let enabledPred = NSPredicate(format: "isEnabled == true")
        let enabledExp = XCTNSPredicateExpectation(predicate: enabledPred, object: undoButton)
        XCTAssertEqual(XCTWaiter.wait(for: [enabledExp], timeout: 5), .completed)
        undoButton.tap()

        // Redo
        let redoButton = app.buttons["redoButton"]
        let redoEnabled = XCTNSPredicateExpectation(predicate: enabledPred, object: redoButton)
        XCTAssertEqual(XCTWaiter.wait(for: [redoEnabled], timeout: 5), .completed)
        redoButton.tap()

        // Redo 後、テキストが復元
        let restored = XCTNSPredicateExpectation(predicate: containsText, object: textEditor)
        let result = XCTWaiter.wait(for: [restored], timeout: 5)
        XCTAssertEqual(result, .completed, "Redo でテキストが復元されるべき")
    }

    // MARK: - 全ボードで動作

    func testUndoRedoButtonsExistOnAllBoards() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        for i in 0..<4 {
            if i > 0 {
                let tabButtons = tabBar.buttons
                guard tabButtons.count > i else { continue }
                tabButtons.element(boundBy: i).tap()
                Thread.sleep(forTimeInterval: 0.5)
            }

            let undoButton = app.buttons["undoButton"]
            let redoButton = app.buttons["redoButton"]
            XCTAssertTrue(undoButton.waitForExistence(timeout: 5),
                          "ボード\(i + 1): Undo ボタンが存在すべき")
            XCTAssertTrue(redoButton.exists,
                          "ボード\(i + 1): Redo ボタンが存在すべき")
        }
    }
}
