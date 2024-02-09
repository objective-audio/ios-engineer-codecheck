import Foundation

actor GitHubAPIClient {
    enum FetchError: Error {
        case makeUrlFailed
    }

    func fetchRepositories(word: String) async throws -> [GitHubRepository] {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = [.init(name: "q", value: word)]

        guard let url = components.url else {
            throw FetchError.makeUrlFailed
        }

        let (data, _) = try await URLSession.shared.data(for: .init(url: url))

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let repositories = try decoder.decode(GitHubRepositories.self, from: data)

        return repositories.items ?? []
    }
}
