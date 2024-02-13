import Foundation

protocol URLSessionForGitHubAPIClient {
    func data(for url: URL) async throws -> Data
}

/// GitHub APIの通信を行うクラス
/// 通信処理をラップし、Structで定義されたリポジトリのデータに変換します

actor GitHubAPIClient: GitHubAPIClientForSearcher {
    enum SearchError: Error {
        case makeUrlFailed
    }

    private let urlSession: URLSessionForGitHubAPIClient

    init(urlSession: URLSessionForGitHubAPIClient = URLSession.shared) {
        self.urlSession = urlSession
    }

    func searchRepositories(word: String) async throws -> [GitHubRepository] {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = [.init(name: "q", value: word)]

        guard let url = components.url else {
            throw SearchError.makeUrlFailed
        }

        let data = try await urlSession.data(for: url)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let repositories = try decoder.decode(GitHubRepositories.self, from: data)

        return repositories.items
    }
}

actor GitHubAPIClientUITestMock: GitHubAPIClientForSearcher {
    private let result: Result<[GitHubRepository], Error>

    init(result: Result<[GitHubRepository], Error>) {
        self.result = result
    }

    func searchRepositories(word: String) async throws -> [GitHubRepository] {
        try result.get()
    }
}
