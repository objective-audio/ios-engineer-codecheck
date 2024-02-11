import Combine
import Foundation

struct NavigationDetail: Equatable {
    let repositoryIndex: Int
}

enum NavigationRouterState {
    case initial
    case main
    case detail(NavigationDetail)
}

enum NavigationElement: Equatable {
    case main
    case detail(NavigationDetail)
}

final class NavigationRouter {
    private let stateSubject: CurrentValueSubject<NavigationRouterState, Never> = .init(.initial)

    var elements: [NavigationElement] {
        stateSubject.value.elements
    }

    var elementsPublisher: AnyPublisher<[NavigationElement], Never> {
        stateSubject.map(\.elements).eraseToAnyPublisher()
    }

    func mainDidAppear() {
        stateSubject.value = .main
    }

    func showDetail(_ detail: NavigationDetail) {
        guard case .main = stateSubject.value else {
            return
        }

        stateSubject.value = .detail(detail)
    }
}

extension NavigationRouterState {
    fileprivate var elements: [NavigationElement] {
        switch self {
        case .initial, .main:
            [.main]
        case let .detail(detail):
            [.main, .detail(detail)]
        }
    }
}
