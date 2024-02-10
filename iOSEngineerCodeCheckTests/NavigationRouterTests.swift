import XCTest

@testable import iOSEngineerCodeCheck

final class NavigationRouterTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_遷移() {
        let router = NavigationRouter()

        XCTAssertEqual(router.elements, [.main])

        XCTContext.runActivity(named: "Mainが表示される前はDetailに遷移できない") { _ in
            router.showDetail(.init(repository: .init(testFullName: "pre_appear")))

            XCTAssertEqual(router.elements, [.main])
        }

        XCTContext.runActivity(named: "Mainが表示されたらDetailに遷移できる") { _ in
            router.mainDidAppear()

            XCTAssertEqual(router.elements, [.main])

            router.showDetail(.init(repository: .init(testFullName: "main_appeared")))

            XCTAssertEqual(
                router.elements,
                [.main, .detail(.init(repository: .init(testFullName: "main_appeared")))])
        }

        XCTContext.runActivity(named: "Detail表示中は重複して遷移できない") { _ in
            router.showDetail(.init(repository: .init(testFullName: "detail_appeared")))

            XCTAssertEqual(
                router.elements,
                [.main, .detail(.init(repository: .init(testFullName: "main_appeared")))])
        }

        XCTContext.runActivity(named: "Detail表示中にMainに戻る") { _ in
            router.mainDidAppear()

            XCTAssertEqual(router.elements, [.main])
        }

        XCTContext.runActivity(named: "Mainに戻ったらDetailに遷移できる") { _ in
            router.showDetail(.init(repository: .init(testFullName: "main_appeared")))

            XCTAssertEqual(
                router.elements,
                [.main, .detail(.init(repository: .init(testFullName: "main_appeared")))])
        }
    }

    func test_elementsの購読() {
        let router = NavigationRouter()

        var received: [[NavigationElement]] = []

        let canceller = router.elementsPublisher.removeDuplicates().sink {
            received.append($0)
        }

        XCTContext.runActivity(named: "購読開始・mainのみ") { _ in
            XCTAssertEqual(received.count, 1)
            XCTAssertEqual(received[0], [.main])
        }

        XCTContext.runActivity(named: "メイン画面が表示される・mainのみで変わらず") { _ in
            router.mainDidAppear()

            XCTAssertEqual(received.count, 1)
        }

        XCTContext.runActivity(named: "詳細画面が表示される・detailが追加") { _ in
            router.showDetail(.init(repository: .init(testFullName: "show_detail")))

            XCTAssertEqual(received.count, 2)
            XCTAssertEqual(
                received[1],
                [.main, .detail(.init(repository: .init(testFullName: "show_detail")))])
        }

        XCTContext.runActivity(named: "メイン画面に戻る・detailが削除") { _ in
            router.mainDidAppear()

            XCTAssertEqual(received.count, 3)
            XCTAssertEqual(received[2], [.main])
        }

        canceller.cancel()
    }
}
