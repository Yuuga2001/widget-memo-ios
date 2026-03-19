import XCTest

final class SnapshotSheetUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }

    // MARK: - ボタン存在

    func testSnapshotButtonExists() throws {
        let button = app.buttons["snapshotButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5), "スナップショットボタンが表示されるべき")
    }

    func testSnapshotButtonIsTappable() throws {
        let button = app.buttons["snapshotButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertTrue(button.isEnabled, "スナップショットボタンはタップ可能であるべき")
    }

    // MARK: - シート表示

    func testSnapshotButtonOpensSheet() throws {
        let button = app.buttons["snapshotButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()

        let title = app.staticTexts["保存履歴"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "保存履歴シートが表示されるべき")
    }

    func testSheetShowsSaveButton() throws {
        let button = app.buttons["snapshotButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()

        let saveButton = app.buttons["saveSnapshotButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "保存ボタンが表示されるべき")
    }

    func testSheetHasNavigationTitle() throws {
        let button = app.buttons["snapshotButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()

        let title = app.navigationBars["保存履歴"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "ナビゲーションタイトルが表示されるべき")
    }

    // MARK: - シート閉じる

    func testSheetCanBeDismissedByCloseButton() throws {
        let button = app.buttons["snapshotButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()

        let title = app.staticTexts["保存履歴"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))

        // ナビゲーションバー内の閉じるボタン
        let navBar = app.navigationBars["保存履歴"]
        let closeButton = navBar.buttons.firstMatch
        if closeButton.waitForExistence(timeout: 3) {
            closeButton.tap()
        } else {
            app.windows.firstMatch.swipeDown()
        }

        let textEditor = app.textViews.firstMatch
        XCTAssertTrue(textEditor.waitForExistence(timeout: 5),
                      "シートを閉じた後メモ画面に戻るべき")
    }

    // MARK: - 保存操作

    func testSaveButtonIsTappable() throws {
        let button = app.buttons["snapshotButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()

        let saveButton = app.buttons["saveSnapshotButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        XCTAssertTrue(saveButton.isEnabled, "保存ボタンはタップ可能であるべき")
        saveButton.tap()
        // クラッシュしなければ成功
    }

    // MARK: - 全ボードで利用可能

    func testSnapshotButtonExistsOnAllBoards() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        for i in 0..<4 {
            if i > 0 {
                let tabButtons = tabBar.buttons
                guard tabButtons.count > i else { continue }
                tabButtons.element(boundBy: i).tap()
                Thread.sleep(forTimeInterval: 0.5)
            }

            let snapshotButton = app.buttons["snapshotButton"]
            XCTAssertTrue(snapshotButton.waitForExistence(timeout: 5),
                          "ボード\(i + 1): スナップショットボタンが存在すべき")
        }
    }
}
