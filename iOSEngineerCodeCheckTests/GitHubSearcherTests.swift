import XCTest

@testable import iOSEngineerCodeCheck

private actor APIClientMock: GitHubAPIClientForSearcher {
    let result: Result<[GitHubRepository], Error>

    init(result: Result<[GitHubRepository], Error>) {
        self.result = result
    }

    func fetchRepositories(word: String) async throws -> [GitHubRepository] {
        try result.get()
    }
}

@MainActor
final class GitHubSearcherTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_検索が成功してデータが返る() {
        let repositories: [GitHubRepository] = [
            .init(testFullName: "foo"), .init(testFullName: "bar"),
        ]
        let apiClient = APIClientMock(result: .success(repositories))
        let searcher = GitHubSearcher(apiClient: apiClient)

        var received: [GitHubSearcherState] = []
        let expectation = XCTestExpectation(description: "fetched")

        let canceller = searcher.statePublisher.sink { state in
            received.append(state)

            if case .loaded = state {
                expectation.fulfill()
            }
        }

        XCTAssertEqual(searcher.state.repositories, [])
        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received[0].repositories, [])

        searcher.search(word: "hoge")

        wait(for: [expectation], timeout: 10.0)

        XCTAssertEqual(searcher.state.repositories, repositories)
        XCTAssertEqual(received.last?.repositories, repositories)

        canceller.cancel()
    }
}
