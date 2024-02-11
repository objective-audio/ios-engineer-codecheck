import Combine
import Foundation

@MainActor
final class MainPresenter {
    private unowned let router: NavigationRouter
    private unowned let searcher: GitHubSearcher

    var repositories: [GitHubRepository] {
        searcher.state.repositories
    }

    var repositoriesPublisher: AnyPublisher<[GitHubRepository], Never> {
        searcher.statePublisher.map(\.repositories).eraseToAnyPublisher()
    }

    init(router: NavigationRouter, searcher: GitHubSearcher) {
        self.router = router
        self.searcher = searcher
    }

    func search(word: String) {
        searcher.search(word: word)
    }

    func cancelSearch() {
        searcher.cancel()
    }

    func didAppear() {
        router.mainDidAppear()
    }

    func showDetail(at index: Int) {
        router.showDetail(.init(repositoryIndex: index))
    }
}
