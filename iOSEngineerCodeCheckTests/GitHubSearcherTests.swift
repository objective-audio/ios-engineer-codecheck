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

        var received: [[GitHubRepository]] = []
        let expectation = XCTestExpectation(description: "fetched")

        let canceller = searcher.repositoriesPublisher.sink { repositories in
            received.append(repositories)

            if !repositories.isEmpty {
                expectation.fulfill()
            }
        }

        XCTAssertEqual(searcher.repositories, [])
        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received[0], [])

        searcher.search(word: "hoge")

        wait(for: [expectation], timeout: 10.0)

        XCTAssertEqual(searcher.repositories, repositories)
        XCTAssertEqual(received.last, repositories)

        canceller.cancel()
    }
}
