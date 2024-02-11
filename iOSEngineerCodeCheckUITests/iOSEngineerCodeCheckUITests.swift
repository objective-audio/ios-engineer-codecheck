import XCTest

class iOSEngineerCodeCheckUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func test_検索して詳細画面を表示() throws {
        let repositories: [GitHubRepository] = [
            .init(
                fullName: "full-name-1", language: "PHP",
                owner: .init(avatarUrl: "https://example.com/eraser"),
                stargazersCount: 11, watchersCount: 12, forksCount: 13, openIssuesCount: 14),
            .init(
                fullName: "full-name-2", language: "Java",
                owner: .init(avatarUrl: "https://example.com/trash"),
                stargazersCount: 21, watchersCount: 22, forksCount: 23, openIssuesCount: 24),
        ]

        let app = XCUIApplication()
        let context = UITestContext(repositories: repositories)
        guard let json = context.encodeToJson() else {
            XCTFail()
            return
        }
        app.launchEnvironment = [UITestContext.environmentKey: json]
        app.launch()

        XCTContext.runActivity(named: "検索フィールドのテキストを入力して確定") { _ in
            let searchField = app.searchFields.firstMatch
            searchField.tap()
            searchField.typeText("dummy")
            app.buttons["Search"].tap()
        }

        XCTContext.runActivity(named: "TableViewに取得したリポジトリが表示される") { _ in
            let cells = app.tables.cells.allElementsBoundByIndex
            XCTAssertEqual(cells.count, 2)

            XCTAssertTrue(cells[0].staticTexts["full-name-1"].exists)
            XCTAssertTrue(cells[0].staticTexts["PHP"].exists)
            XCTAssertTrue(cells[1].staticTexts["full-name-2"].exists)
            XCTAssertTrue(cells[1].staticTexts["Java"].exists)
        }

        XCTContext.runActivity(named: "1つ目のセルをタップしDetailが表示される") { _ in
            app.tables.cells.element(boundBy: 0).tap()

            XCTAssertTrue(app.staticTexts["full-name-1"].exists)
            XCTAssertTrue(app.staticTexts["Written in PHP"].exists)
            XCTAssertTrue(app.staticTexts["11 stars"].exists)
            XCTAssertTrue(app.staticTexts["12 watchers"].exists)
            XCTAssertTrue(app.staticTexts["13 forks"].exists)
            XCTAssertTrue(app.staticTexts["14 open issues"].exists)

            XCTAssertTrue(app.images["eraser"].exists)
        }
    }
}
