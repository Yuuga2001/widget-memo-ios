import XCTest

final class WatchUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - 起動・初期表示

    func testAppLaunches() throws {
        // アプリが正常に起動し、最初のボード（デフォルトテキスト）が表示される
        XCTAssertTrue(app.staticTexts["メモを入力"].waitForExistence(timeout: 5))
    }

    func testFirstBoardShowsBoardName() throws {
        // ボード名「1」が表示されている
        XCTAssertTrue(app.staticTexts["1"].waitForExistence(timeout: 5))
    }

    func testFirstBoardShowsDefaultText() throws {
        // デフォルトテキスト「メモを入力」が表示されている
        let memoText = app.staticTexts["メモを入力"]
        XCTAssertTrue(memoText.waitForExistence(timeout: 5))
    }

    // MARK: - ボード切り替え（横スワイプ）

    func testSwipeLeftShowsSecondBoard() throws {
        // 左スワイプでボード2（名前「2」）に切り替わる
        let memoText = app.staticTexts["メモを入力"]
        XCTAssertTrue(memoText.waitForExistence(timeout: 5))

        app.swipeLeft()
        sleep(1)

        // ボード名「2」が表示される
        XCTAssertTrue(app.staticTexts["2"].waitForExistence(timeout: 3))
    }

    func testSwipeToThirdBoard() throws {
        let memoText = app.staticTexts["メモを入力"]
        XCTAssertTrue(memoText.waitForExistence(timeout: 5))

        // 2回左スワイプでボード3へ
        app.swipeLeft()
        sleep(1)
        app.swipeLeft()
        sleep(1)

        XCTAssertTrue(app.staticTexts["3"].waitForExistence(timeout: 3))
    }

    func testSwipeToFourthBoard() throws {
        let memoText = app.staticTexts["メモを入力"]
        XCTAssertTrue(memoText.waitForExistence(timeout: 5))

        // 3回左スワイプでボード4へ
        app.swipeLeft()
        sleep(1)
        app.swipeLeft()
        sleep(1)
        app.swipeLeft()
        sleep(1)

        XCTAssertTrue(app.staticTexts["4"].waitForExistence(timeout: 3))
    }

    func testSwipeBackToFirstBoard() throws {
        let memoText = app.staticTexts["メモを入力"]
        XCTAssertTrue(memoText.waitForExistence(timeout: 5))

        // ボード2へ移動して戻る
        app.swipeLeft()
        sleep(1)
        XCTAssertTrue(app.staticTexts["2"].waitForExistence(timeout: 3))

        app.swipeRight()
        sleep(1)
        XCTAssertTrue(app.staticTexts["1"].waitForExistence(timeout: 3))
    }

    // MARK: - 全ボード巡回

    func testAllBoardsAccessible() throws {
        // すべてのボード（1〜4）にアクセスできることを確認
        XCTAssertTrue(app.staticTexts["1"].waitForExistence(timeout: 5))

        app.swipeLeft()
        sleep(1)
        XCTAssertTrue(app.staticTexts["2"].waitForExistence(timeout: 3))

        app.swipeLeft()
        sleep(1)
        XCTAssertTrue(app.staticTexts["3"].waitForExistence(timeout: 3))

        app.swipeLeft()
        sleep(1)
        XCTAssertTrue(app.staticTexts["4"].waitForExistence(timeout: 3))

        // 最後のボードで左スワイプしても4のまま（ページ外に出ない）
        app.swipeLeft()
        sleep(1)
        XCTAssertTrue(app.staticTexts["4"].waitForExistence(timeout: 3))
    }

    // MARK: - テキスト表示

    func testAllBoardsShowDefaultText() throws {
        // 各ボードでデフォルトテキストが表示されることを確認
        for i in 0..<4 {
            if i > 0 {
                app.swipeLeft()
                sleep(1)
            }
            XCTAssertTrue(
                app.staticTexts["メモを入力"].waitForExistence(timeout: 3),
                "ボード\(i + 1)でデフォルトテキストが表示されない"
            )
        }
    }
}
