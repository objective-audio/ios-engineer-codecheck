import Foundation

@testable import iOSEngineerCodeCheck

extension GitHubRepository {
    init(testFullName: String) {
        self.init(
            fullName: testFullName, language: nil, owner: nil, stargazersCount: nil,
            watchersCount: nil, forksCount: nil, openIssuesCount: nil)
    }

    init(owner: GitHubOwner?) {
        self.init(
            fullName: nil, language: nil, owner: owner, stargazersCount: nil, watchersCount: nil,
            forksCount: nil, openIssuesCount: nil)
    }
}
