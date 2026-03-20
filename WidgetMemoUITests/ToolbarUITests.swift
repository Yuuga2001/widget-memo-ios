import XCTest

final class ToolbarUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }

    // MARK: - コピーボタン

    func testCopyButtonExists() throws {
        let copyButton = app.buttons["copyButton"]
        XCTAssertTrue(copyButton.waitForExistence(timeout: 5), "コピーボタンが表示されるべき")
    }

    func testCopyButtonIsTappable() throws {
        let copyButton = app.buttons["copyButton"]
        XCTAssertTrue(copyButton.waitForExistence(timeout: 5))
        XCTAssertTrue(copyButton.isEnabled, "コピーボタンはタップ可能であるべき")
        copyButton.tap()
        // クラッシュしなければ成功
    }

    func testCopyButtonExistsOnAllBoards() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        for i in 0..<4 {
            if i > 0 {
                let tabButtons = tabBar.buttons
                guard tabButtons.count > i else { continue }
                tabButtons.element(boundBy: i).tap()
                Thread.sleep(forTimeInterval: 0.5)
            }

            let copyButton = app.buttons["copyButton"]
            XCTAssertTrue(copyButton.waitForExistence(timeout: 5),
                          "ボード\(i + 1): コピーボタンが存在すべき")
        }
    }

    // MARK: - ヘルプボタン

    func testHelpButtonExists() throws {
        let helpButton = app.buttons["helpButton"]
        XCTAssertTrue(helpButton.waitForExistence(timeout: 5), "ヘルプボタンが表示されるべき")
    }

    func testHelpButtonOpensGuide() throws {
        let helpButton = app.buttons["helpButton"]
        XCTAssertTrue(helpButton.waitForExistence(timeout: 5))
        helpButton.tap()

        // ヘルプガイドのタイトルが表示される
        let title = app.staticTexts["How to Use"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "ヘルプガイド画面が表示されるべき")
    }

    func testHelpGuideContainsSections() throws {
        let helpButton = app.buttons["helpButton"]
        XCTAssertTrue(helpButton.waitForExistence(timeout: 5))
        helpButton.tap()

        let widgetSection = app.staticTexts["Quick Add from App Icon"]
        XCTAssertTrue(widgetSection.waitForExistence(timeout: 5),
                      "アプリアイコンからの追加セクションが表示されるべき")
    }

    func testHelpGuideCanBeDismissed() throws {
        let helpButton = app.buttons["helpButton"]
        XCTAssertTrue(helpButton.waitForExistence(timeout: 5))
        helpButton.tap()

        let title = app.staticTexts["How to Use"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))

        // 閉じるボタンをタップ
        let closeButton = app.buttons["xmark.circle.fill"]
        if closeButton.waitForExistence(timeout: 3) {
            closeButton.tap()
        } else {
            // 下スワイプで閉じる
            let window = app.windows.firstMatch
            window.swipeDown()
        }

        // ヘルプ画面が閉じてメモ画面に戻る
        let textEditor = app.textViews.firstMatch
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5),
                      "ヘルプ画面を閉じた後メモ画面に戻るべき")
    }

    // MARK: - ツールバー全体

    func testAllToolbarButtonsExist() throws {
        let snapshotButton = app.buttons["snapshotButton"]
        let undoButton = app.buttons["undoButton"]
        let redoButton = app.buttons["redoButton"]
        let copyButton = app.buttons["copyButton"]
        let helpButton = app.buttons["helpButton"]

        XCTAssertTrue(snapshotButton.waitForExistence(timeout: 5), "スナップショットボタンが存在すべき")
        XCTAssertTrue(undoButton.exists, "Undo ボタンが存在すべき")
        XCTAssertTrue(redoButton.exists, "Redo ボタンが存在すべき")
        XCTAssertTrue(copyButton.exists, "コピーボタンが存在すべき")
        XCTAssertTrue(helpButton.exists, "ヘルプボタンが存在すべき")
    }
}
