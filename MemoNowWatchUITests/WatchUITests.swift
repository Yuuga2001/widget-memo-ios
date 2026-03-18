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

    // MARK: - Helper

    /// ページインジケータの value で現在のページを確認
    private func assertCurrentPage(_ page: Int, file: StaticString = #file, line: UInt = #line) {
        let expected = "全4ページ中の\(page)ページ目"
        let predicate = NSPredicate(format: "value == %@", expected)
        let indicator = app.otherElements.matching(predicate).firstMatch
        XCTAssertTrue(
            indicator.waitForExistence(timeout: 3),
            "ページ\(page)のインジケータが見つからない",
            file: file, line: line
        )
    }

    // MARK: - 起動・初期表示

    func testAppLaunches() throws {
        // アプリが正常に起動し、デフォルトテキストが表示される
        XCTAssertTrue(app.staticTexts["メモを入力"].waitForExistence(timeout: 5))
    }

    func testFirstBoardShowsDefaultText() throws {
        // デフォルトテキスト「メモを入力」が iOS と同じ内容で表示されている
        XCTAssertTrue(app.staticTexts["メモを入力"].waitForExistence(timeout: 5))
    }

    func testFirstPageIndicator() throws {
        // ページインジケータが「全4ページ中の1ページ目」であること
        assertCurrentPage(1)
    }

    // MARK: - iOS と同じデータ表示（文字サイズ・背景色・文字色）
    // store.fontSize / store.backgroundColor / store.textColor を
    // そのまま使用。UIテストではデフォルト値の表示で検証。

    func testAllBoardsShowDefaultMemoText() throws {
        // 各ボードで iOS と同じデフォルトテキスト「メモを入力」が表示される
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

    // MARK: - 横スワイプでボード切り替え

    func testSwipeLeftShowsSecondBoard() throws {
        XCTAssertTrue(app.staticTexts["メモを入力"].waitForExistence(timeout: 5))

        app.swipeLeft()
        sleep(1)

        assertCurrentPage(2)
    }

    func testSwipeToThirdBoard() throws {
        XCTAssertTrue(app.staticTexts["メモを入力"].waitForExistence(timeout: 5))

        app.swipeLeft()
        sleep(1)
        app.swipeLeft()
        sleep(1)

        assertCurrentPage(3)
    }

    func testSwipeToFourthBoard() throws {
        XCTAssertTrue(app.staticTexts["メモを入力"].waitForExistence(timeout: 5))

        app.swipeLeft()
        sleep(1)
        app.swipeLeft()
        sleep(1)
        app.swipeLeft()
        sleep(1)

        assertCurrentPage(4)
    }

    func testSwipeBackToFirstBoard() throws {
        XCTAssertTrue(app.staticTexts["メモを入力"].waitForExistence(timeout: 5))

        app.swipeLeft()
        sleep(1)
        assertCurrentPage(2)

        app.swipeRight()
        sleep(1)
        assertCurrentPage(1)
    }

    func testLastBoardDoesNotOverscroll() throws {
        // 最後のボードで左スワイプしてもページ4のまま
        XCTAssertTrue(app.staticTexts["メモを入力"].waitForExistence(timeout: 5))

        for _ in 0..<3 {
            app.swipeLeft()
            sleep(1)
        }
        assertCurrentPage(4)

        app.swipeLeft()
        sleep(1)
        assertCurrentPage(4)
    }

    // MARK: - 縦スクロール（スワイプ & ホイール）

    func testVerticalSwipeDoesNotChangeBoard() throws {
        // 縦スワイプでスクロールしてもボードが切り替わらないことを確認
        XCTAssertTrue(app.staticTexts["メモを入力"].waitForExistence(timeout: 5))

        app.swipeUp()
        sleep(1)
        assertCurrentPage(1)

        app.swipeDown()
        sleep(1)
        assertCurrentPage(1)
    }

    func testScrollAfterBoardSwitch() throws {
        // ボード切り替え後も縦スクロールが正常動作することを確認
        XCTAssertTrue(app.staticTexts["メモを入力"].waitForExistence(timeout: 5))

        app.swipeLeft()
        sleep(1)
        assertCurrentPage(2)

        // ボード2で縦スワイプしてもボードが変わらない
        app.swipeUp()
        sleep(1)
        assertCurrentPage(2)
    }
}
