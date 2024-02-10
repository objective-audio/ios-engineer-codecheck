import Combine
import Foundation

protocol GitHubAPIClientForSearcher {
    func fetchRepositories(word: String) async throws -> [GitHubRepository]
}

@MainActor
final class GitHubSearcher {
    private let apiClient: GitHubAPIClientForSearcher

    private let stateSubject: CurrentValueSubject<GitHubSearcherState, Never> = .init(.initial)
    private(set) var state: GitHubSearcherState {
        get { stateSubject.value }
        set { stateSubject.value = newValue }
    }
    var statePublisher: AnyPublisher<GitHubSearcherState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    init(apiClient: GitHubAPIClientForSearcher = GitHubAPIClient()) {
        self.apiClient = apiClient
    }

    func search(word: String) {
        guard word.count > 0 else { return }

        state.task?.cancel()

        let task = Task {
            do {
                let repositories = try await apiClient.fetchRepositories(word: word)
                state = .loaded(repositories)
            } catch {
                state = .failed(error, state.repositories)
            }
        }

        state = .loading(task, state.repositories)
    }

    func cancel() {
        state.task?.cancel()
        state = .loaded(state.repositories)
    }
}
