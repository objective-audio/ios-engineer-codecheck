import Foundation

protocol URLSessionForGitHubAPIClient {
    func data(for url: URL) async throws -> Data
}

actor GitHubAPIClient: GitHubAPIClientForSearcher {
    enum FetchError: Error {
        case makeUrlFailed
    }

    private let urlSession: URLSessionForGitHubAPIClient

    init(urlSession: URLSessionForGitHubAPIClient = URLSession.shared) {
        self.urlSession = urlSession
    }

    func fetchRepositories(word: String) async throws -> [GitHubRepository] {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = [.init(name: "q", value: word)]

        guard let url = components.url else {
            throw FetchError.makeUrlFailed
        }

        let data = try await urlSession.data(for: url)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let repositories = try decoder.decode(GitHubRepositories.self, from: data)

        return repositories.items
    }
}
