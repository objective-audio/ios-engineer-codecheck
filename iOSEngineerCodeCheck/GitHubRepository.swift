import Foundation

struct GitHubRepositories: Decodable {
    let items: [GitHubRepository]?
}

struct GitHubRepository: Decodable {
    let fullName: String?
    let language: String?
    let owner: GitHubOwner?
    let stargazersCount: Int?
    let watchersCount: Int?
    let forksCount: Int?
    let openIssuesCount: Int?
}

struct GitHubOwner: Decodable {
    let avatarUrl: String?
}
