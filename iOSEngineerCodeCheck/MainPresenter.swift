import Combine
import Foundation

@MainActor
final class MainPresenter {
    private unowned let searcher: GitHubSearcher

    private let contentSubject: CurrentValueSubject<MainContent, Never> = .init(
        .init(cellContents: [], message: .waiting))
    var content: MainContent { contentSubject.value }
    var contentPublisher: AnyPublisher<MainContent, Never> {
        contentSubject.eraseToAnyPublisher()
    }

    private var cancellables: Set<AnyCancellable> = []

    init(searcher: GitHubSearcher) {
        self.searcher = searcher

        searcher.statePublisher.map(\.mainContent).subscribe(contentSubject).store(
            in: &cancellables)
    }
}

extension GitHubSearcherState {
    fileprivate var mainContent: MainContent {
        .init(cellContents: mainCellContents, message: message)
    }

    fileprivate var mainCellContents: [MainCellContent] {
        repositories.map(\.mainCellContent)
    }

    fileprivate var message: MainMessage {
        switch self {
        case .initial, .cancelled:
            .waiting
        case .loaded:
            .loaded
        case .loading:
            .loading
        case .failed:
            .failed
        }
    }
}

extension GitHubRepository {
    fileprivate var mainCellContent: MainCellContent {
        .init(fullName: fullName, language: language)
    }
}
