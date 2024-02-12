import Foundation

extension URLSession: URLSessionForGitHubAPIClient {
    func data(for url: URL) async throws -> Data {
        try await data(for: .init(url: url), delegate: nil).0
    }
}
