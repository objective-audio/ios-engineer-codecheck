import Foundation

struct GitHubRepositories: Decodable {
    let items: [GitHubRepository]
}

struct GitHubRepository: Codable, Equatable {
    let fullName: String?
    let language: String?
    let owner: GitHubOwner?
    let stargazersCount: Int?
    let watchersCount: Int?
    let forksCount: Int?
    let openIssuesCount: Int?
}

struct GitHubOwner: Codable, Equatable {
    let avatarUrl: String?
}

extension GitHubRepository {
    var avatarUrl: URL? {
        guard let urlString = owner?.avatarUrl, let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
}
