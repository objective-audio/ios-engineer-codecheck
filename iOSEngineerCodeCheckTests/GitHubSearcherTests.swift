import XCTest

@testable import iOSEngineerCodeCheck

private actor APIClientMock: GitHubAPIClientForSearcher {
    let result: Result<[GitHubRepository], Error>

    init(result: Result<[GitHubRepository], Error>) {
        self.result = result
    }

    func searchRepositories(word: String) async throws -> [GitHubRepository] {
        try result.get()
    }
}

private enum GitHubSearcherMatchState {
    case initial
    case loading([GitHubRepository])
    case loaded([GitHubRepository])
    case failed([GitHubRepository])
}

extension GitHubSearcherState {
    fileprivate func isMatch(_ rhs: GitHubSearcherMatchState) -> Bool {
        switch (self, rhs) {
        case (.initial, .initial):
            true
        case (.loading(_, let lhsRepos), .loading(let rhsRepos)),
            (.loaded(let lhsRepos), .loaded(let rhsRepos)),
            (.failed(_, let lhsRepos), .failed(let rhsRepos)):
            lhsRepos == rhsRepos
        default:
            false
        }
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

        XCTAssertTrue(searcher.state.isMatch(.initial))
        XCTAssertEqual(received.count, 1)
        XCTAssertTrue(received[0].isMatch(.initial))

        searcher.search(word: "hoge")

        wait(for: [expectation], timeout: 10.0)

        XCTAssertTrue(searcher.state.isMatch(.loaded(repositories)))

        XCTAssertEqual(received.count, 3)
        XCTAssertTrue(received[1].isMatch(.loading([])))
        XCTAssertTrue(received[2].isMatch(.loaded(repositories)))

        canceller.cancel()
    }

    func test_検索が失敗してデータは空のまま() {
        let apiClient = APIClientMock(result: .failure(TestError.dummy))
        let searcher = GitHubSearcher(apiClient: apiClient)

        var received: [GitHubSearcherState] = []
        let expectation = XCTestExpectation(description: "failed")

        let canceller = searcher.statePublisher.sink { state in
            received.append(state)

            if case .failed = state {
                expectation.fulfill()
            }
        }

        XCTAssertTrue(searcher.state.isMatch(.initial))
        XCTAssertEqual(received.count, 1)
        XCTAssertTrue(received[0].isMatch(.initial))

        searcher.search(word: "hoge")

        wait(for: [expectation], timeout: 10.0)

        XCTAssertTrue(searcher.state.isMatch(.failed([])))

        XCTAssertEqual(received.count, 3)
        XCTAssertTrue(received[1].isMatch(.loading([])))
        XCTAssertTrue(received[2].isMatch(.failed([])))

        canceller.cancel()
    }
}
