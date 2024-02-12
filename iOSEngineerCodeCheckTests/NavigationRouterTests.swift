import XCTest

@testable import iOSEngineerCodeCheck

@MainActor
final class NavigationRouterTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_遷移() {
        let factory = ImageCacheFactory(isTest: true)
        let router = NavigationRouter(imageCacheFactory: factory)

        XCTAssertEqual(router.elements, [.main])

        XCTContext.runActivity(named: "Mainが表示される前はDetailに遷移できない") { _ in
            router.showDetail(repositoryIndex: 0)

            XCTAssertEqual(router.elements, [.main])
        }

        XCTContext.runActivity(named: "Mainが表示されたらDetailに遷移できる") { _ in
            router.mainDidAppear()

            XCTAssertEqual(router.elements, [.main])

            router.showDetail(repositoryIndex: 1)

            XCTAssertEqual(
                router.elements,
                [.main, .detail(.init(repositoryIndex: 1))])
        }

        XCTContext.runActivity(named: "Detail表示中は重複して遷移できない") { _ in
            router.showDetail(repositoryIndex: 2)

            XCTAssertEqual(
                router.elements,
                [.main, .detail(.init(repositoryIndex: 1))])
        }

        XCTContext.runActivity(named: "Detail表示中にMainに戻る") { _ in
            router.mainDidAppear()

            XCTAssertEqual(router.elements, [.main])
        }

        XCTContext.runActivity(named: "Mainに戻ったらDetailに遷移できる") { _ in
            router.showDetail(repositoryIndex: 3)

            XCTAssertEqual(
                router.elements,
                [.main, .detail(.init(repositoryIndex: 3))])
        }
    }

    func test_elementsの購読() {
        let factory = ImageCacheFactory(isTest: true)
        let router = NavigationRouter(imageCacheFactory: factory)

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
            router.showDetail(repositoryIndex: 0)

            XCTAssertEqual(received.count, 2)
            XCTAssertEqual(
                received[1],
                [.main, .detail(.init(repositoryIndex: 0))])
        }

        XCTContext.runActivity(named: "メイン画面に戻る・detailが削除") { _ in
            router.mainDidAppear()

            XCTAssertEqual(received.count, 3)
            XCTAssertEqual(received[2], [.main])
        }

        canceller.cancel()
    }
}
