import XCTest

@testable import iOSEngineerCodeCheck

private actor URLSessionSuccessMock: URLSessionForGitHubAPIClient {
    var receivedURL: URL?

    func data(for url: URL) async throws -> Data {
        receivedURL = url

        let jsonUrl = Bundle(for: Self.self).url(
            forResource: "github-repositories", withExtension: "json")!
        let json = try String(contentsOf: jsonUrl, encoding: .utf8)
        return json.data(using: .utf8)!
    }
}

private actor URLSessionFailureMock: URLSessionForGitHubAPIClient {
    func data(for url: URL) async throws -> Data {
        return Data()
    }
}

final class GitHubAPIClientTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_検索に成功しデータが返る() async throws {
        let urlSession = URLSessionSuccessMock()
        let apiClient = GitHubAPIClient(urlSession: urlSession)

        let repositories = try await apiClient.searchRepositories(word: "test-word")

        let receivedURL = await urlSession.receivedURL
        XCTAssertEqual(
            receivedURL?.absoluteString, "https://api.github.com/search/repositories?q=test-word")

        let expected: [GitHubRepository] = [
            .init(
                fullName: "full-name-1", language: "PHP",
                owner: .init(avatarUrl: "https://avatars.githubusercontent.com/u/1?v=4"),
                stargazersCount: 101, watchersCount: 102, forksCount: 103, openIssuesCount: 104),
            .init(
                fullName: "full-name-2", language: "Java",
                owner: .init(avatarUrl: "https://avatars.githubusercontent.com/u/2?v=4"),
                stargazersCount: 201, watchersCount: 202, forksCount: 203, openIssuesCount: 204),
        ]

        XCTAssertEqual(repositories, expected)
    }

    func test_検索に失敗しエラーが返る() async throws {
        let urlSession = URLSessionFailureMock()
        let apiClient = GitHubAPIClient(urlSession: urlSession)

        do {
            _ = try await apiClient.searchRepositories(word: "test-word")
            XCTFail()
        } catch {
            // OK
        }
    }
}
