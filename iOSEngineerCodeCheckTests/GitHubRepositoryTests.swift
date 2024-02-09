import XCTest

@testable import iOSEngineerCodeCheck

final class GitHubRepositoryTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test_avatarUrl() {
        XCTContext.runActivity(named: "ownerのavatarUrlが正しければURLを返す") { _ in
            let owner = GitHubOwner(avatarUrl: "https://example.com/")
            let repository = GitHubRepository(
                fullName: nil, language: nil, owner: owner, stargazersCount: nil,
                watchersCount: nil,
                forksCount: nil, openIssuesCount: nil)

            XCTAssertEqual(repository.avatarUrl?.absoluteString, "https://example.com/")
        }

        XCTContext.runActivity(named: "ownerのavatarUrlが不正ならnilを返す") { _ in
            let owner = GitHubOwner(avatarUrl: "")
            let repository = GitHubRepository(
                fullName: nil, language: nil, owner: owner, stargazersCount: nil,
                watchersCount: nil,
                forksCount: nil, openIssuesCount: nil)

            XCTAssertNil(repository.avatarUrl)
        }

        XCTContext.runActivity(named: "ownerがnilならnilを返す") { _ in
            let repository = GitHubRepository(
                fullName: nil, language: nil, owner: nil, stargazersCount: nil, watchersCount: nil,
                forksCount: nil, openIssuesCount: nil)

            XCTAssertNil(repository.avatarUrl)
        }
    }
}
