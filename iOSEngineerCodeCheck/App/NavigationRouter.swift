import Combine
import Foundation

struct NavigationDetail: Equatable {
    let repositoryIndex: Int
}

enum NavigationRouterState {
    case initial
    case main
    case detail(Detail)
}

enum NavigationElement: Equatable {
    case main
    case detail(NavigationDetail)
}

@MainActor
final class NavigationRouter {
    private unowned let imageCacheFactory: ImageCacheFactory
    private let stateSubject: CurrentValueSubject<NavigationRouterState, Never> = .init(.initial)

    var state: NavigationRouterState {
        stateSubject.value
    }

    init(imageCacheFactory: ImageCacheFactory) {
        self.imageCacheFactory = imageCacheFactory
    }

    var elements: [NavigationElement] {
        stateSubject.value.elements
    }

    var elementsPublisher: AnyPublisher<[NavigationElement], Never> {
        stateSubject.map(\.elements).eraseToAnyPublisher()
    }

    func mainDidAppear() {
        stateSubject.value = .main
    }

    func showDetail(repositoryIndex: Int) {
        guard case .main = stateSubject.value else {
            return
        }

        stateSubject.value = .detail(
            .init(repositoryIndex: repositoryIndex, imageCache: imageCacheFactory.makeImageCache()))
    }
}

extension NavigationRouterState {
    fileprivate var elements: [NavigationElement] {
        switch self {
        case .initial, .main:
            [.main]
        case let .detail(detail):
            [.main, .detail(.init(repositoryIndex: detail.repositoryIndex))]
        }
    }
}
