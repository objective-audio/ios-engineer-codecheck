import Combine
import Foundation

enum NavigationRouterState {
    case initial
    case main
    case detail(Detail)
}

enum NavigationElement: Equatable {
    case main
    case detail(repositoryIndex: Int)
}

/// ナビゲーションの遷移を管理するクラス
/// Viewに依存せず、ナビゲーションの状態を配列で保持して管理します
/// Main画面がアクティブな時だけDetail画面に遷移できるように制限しています

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
        // Main画面表示中しかDetail画面には遷移できない
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
            [.main, .detail(repositoryIndex: detail.repositoryIndex)]
        }
    }
}
