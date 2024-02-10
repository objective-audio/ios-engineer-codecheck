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
            let repository = GitHubRepository(owner: owner)

            XCTAssertEqual(repository.avatarUrl?.absoluteString, "https://example.com/")
        }

        XCTContext.runActivity(named: "ownerのavatarUrlが不正ならnilを返す") { _ in
            let owner = GitHubOwner(avatarUrl: "")
            let repository = GitHubRepository(owner: owner)

            XCTAssertNil(repository.avatarUrl)
        }

        XCTContext.runActivity(named: "ownerがnilならnilを返す") { _ in
            let repository = GitHubRepository(owner: nil)

            XCTAssertNil(repository.avatarUrl)
        }
    }
}
