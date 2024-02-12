import XCTest

@testable import iOSEngineerCodeCheck

private final class APIClientMock: GitHubAPIClientForSearcher {
    let handler: (CheckedContinuation<[GitHubRepository], Error>) -> Void

    init(
        handler: @escaping (CheckedContinuation<[GitHubRepository], Error>) -> Void
    ) {
        self.handler = handler
    }

    func searchRepositories(word: String) async throws -> [GitHubRepository] {
        try await withCheckedThrowingContinuation { continuation in
            handler(continuation)
        }
    }
}

private enum GitHubSearcherMatchState {
    case initial
    case loading([GitHubRepository])
    case loaded([GitHubRepository])
    case failed([GitHubRepository])
    case cancelled([GitHubRepository])
}

extension GitHubSearcherState {
    fileprivate func isMatch(_ rhs: GitHubSearcherMatchState) -> Bool {
        switch (self, rhs) {
        case (.initial, .initial):
            true
        case (.loading(_, let lhsRepos), .loading(let rhsRepos)),
            (.loaded(let lhsRepos), .loaded(let rhsRepos)),
            (.failed(_, let lhsRepos), .failed(let rhsRepos)),
            (.cancelled(let lhsRepos), .cancelled(let rhsRepos)):
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
        let apiClient = APIClientMock { continuation in
            continuation.resume(returning: repositories)
        }
        let searcher = GitHubSearcher(apiClient: apiClient)

        var received: [GitHubSearcherState] = []
        let expectation = XCTestExpectation(description: "searched")

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
        let apiClient = APIClientMock { continuation in
            continuation.resume(throwing: TestError.dummy)
        }
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

    func test_検索中にキャンセルしデータは空のまま() {
        let repositories: [GitHubRepository] = [
            .init(testFullName: "foo"), .init(testFullName: "bar"),
        ]
        let continuationExpectation = XCTestExpectation(description: "continuation")
        var receivedContinuation: CheckedContinuation<[GitHubRepository], Error>?
        let apiClient = APIClientMock { continuation in
            receivedContinuation = continuation
            continuationExpectation.fulfill()
        }
        let searcher = GitHubSearcher(apiClient: apiClient)

        var received: [GitHubSearcherState] = []
        let cancelledExpectation = XCTestExpectation(description: "cancelled")

        let canceller = searcher.statePublisher.sink { state in
            received.append(state)

            if case .cancelled = state {
                cancelledExpectation.fulfill()
            }
        }

        XCTAssertTrue(searcher.state.isMatch(.initial))
        XCTAssertEqual(received.count, 1)
        XCTAssertTrue(received[0].isMatch(.initial))

        searcher.search(word: "hoge")

        wait(for: [continuationExpectation], timeout: 10.0)

        XCTAssertTrue(searcher.state.isMatch(.loading([])))

        XCTAssertEqual(received.count, 2)
        XCTAssertTrue(received[1].isMatch(.loading([])))

        searcher.cancel()

        receivedContinuation?.resume(returning: repositories)

        wait(for: [cancelledExpectation], timeout: 10.0)

        XCTAssertTrue(searcher.state.isMatch(.cancelled([])))

        XCTAssertEqual(received.count, 3)
        XCTAssertTrue(received[2].isMatch(.cancelled([])))

        canceller.cancel()
    }
}
