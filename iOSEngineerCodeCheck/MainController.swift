import Foundation

@MainActor
final class MainController {
    private unowned let router: NavigationRouter
    private unowned let searcher: GitHubSearcher

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
        router.showDetail(repositoryIndex: index)
    }
}
