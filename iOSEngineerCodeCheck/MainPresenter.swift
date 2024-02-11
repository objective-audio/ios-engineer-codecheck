import Combine
import Foundation

@MainActor
final class MainPresenter {
    private unowned let router: NavigationRouter
    private unowned let searcher: GitHubSearcher

    private let contentsSubject: CurrentValueSubject<[MainCellContent], Never> = .init([])
    var contents: [MainCellContent] { contentsSubject.value }
    var contentsPublisher: AnyPublisher<[MainCellContent], Never> {
        contentsSubject.eraseToAnyPublisher()
    }

    private var cancellables: Set<AnyCancellable> = []

    init(router: NavigationRouter, searcher: GitHubSearcher) {
        self.router = router
        self.searcher = searcher

        searcher.statePublisher.map(\.mainCellContents).subscribe(contentsSubject).store(
            in: &cancellables)
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

extension GitHubSearcherState {
    fileprivate var mainCellContents: [MainCellContent] {
        repositories.map(\.mainCellContent)
    }
}

extension GitHubRepository {
    fileprivate var mainCellContent: MainCellContent {
        .init(fullName: fullName, language: language)
    }
}
