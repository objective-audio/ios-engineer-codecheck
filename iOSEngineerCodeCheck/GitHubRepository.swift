import Foundation

struct GitHubRepository: Decodable {
    let fullName: String?
    let language: String?
    let owner: GitHubOwner?
    let stargazersCount: Int?
    let wachersCount: Int?
    let forksCount: Int?
    let openIssuesCount: Int?
}

struct GitHubOwner: Decodable {
    let avatarUrl: String?
}
