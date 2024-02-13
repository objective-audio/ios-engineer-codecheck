import Combine
import Foundation

protocol GitHubAPIClientForSearcher {
    func searchRepositories(word: String) async throws -> [GitHubRepository]
}

/// GitHubのリポジトリを検索するクラス
/// 非同期の通信をラップして、データの取得状態をプロパティで取得できるようにしています

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

    init(apiClient: GitHubAPIClientForSearcher) {
        self.apiClient = apiClient
    }

    func search(word: String) {
        guard word.count > 0 else { return }

        state.task?.cancel()

        let task = Task {
            do {
                let repositories = try await apiClient.searchRepositories(word: word)

                // キャンセルされていたらレスポンスが返ってきても無視する
                if !state.isCancelled {
                    state = .loaded(repositories)
                }
            } catch {
                // キャンセルされていたらエラーが返ってきても無視する
                if !state.isCancelled {
                    state = .failed(error, state.repositories)
                }
            }
        }

        state = .loading(task, state.repositories)
    }

    func cancel() {
        state = .cancelled(state.repositories)
        state.task?.cancel()
    }
}

extension GitHubSearcherState {
    fileprivate var isCancelled: Bool {
        guard case .cancelled = self else { return false }
        return true
    }
}
