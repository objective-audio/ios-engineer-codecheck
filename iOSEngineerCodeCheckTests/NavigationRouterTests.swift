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
}
