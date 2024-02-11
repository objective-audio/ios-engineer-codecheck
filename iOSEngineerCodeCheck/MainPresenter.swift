import Combine
import Foundation

@MainActor
final class MainPresenter {
    private unowned let searcher: GitHubSearcher

    private let contentsSubject: CurrentValueSubject<[MainCellContent], Never> = .init([])
    var contents: [MainCellContent] { contentsSubject.value }
    var contentsPublisher: AnyPublisher<[MainCellContent], Never> {
        contentsSubject.eraseToAnyPublisher()
    }

    private var cancellables: Set<AnyCancellable> = []

    init(searcher: GitHubSearcher) {
        self.searcher = searcher

        searcher.statePublisher.map(\.mainCellContents).subscribe(contentsSubject).store(
            in: &cancellables)
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
