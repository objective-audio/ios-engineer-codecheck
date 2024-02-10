import Combine
import Foundation

@MainActor
final class GitHubSearcher {
    private let apiClient: GitHubAPIClient = .init()

    private let repositoriesSubject: CurrentValueSubject<[GitHubRepository], Never> = .init([])
    var repositories: [GitHubRepository] { repositoriesSubject.value }
    var repositoriesPublisher: AnyPublisher<[GitHubRepository], Never> {
        repositoriesSubject.eraseToAnyPublisher()
    }

    private var task: Task<Void, Error>?

    func search(word: String) {
        guard word.count > 0 else { return }

        cancel()

        task = Task {
            let repositories = try await apiClient.fetchRepositories(word: word)
            repositoriesSubject.value = repositories
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
