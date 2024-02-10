import Combine
import Foundation

struct NavigationDetail {
    let repository: GitHubRepository
}

enum NavigationElement {
    case main
    case detail(NavigationDetail)
}

final class NavigationRouter {
    private let detailSubject: CurrentValueSubject<NavigationDetail?, Never> = .init(nil)

    var elements: [NavigationElement] {
        detailSubject.value.elements
    }

    var elementsPublisher: AnyPublisher<[NavigationElement], Never> {
        detailSubject.map(\.elements).eraseToAnyPublisher()
    }

    func mainDidAppear() {
        detailSubject.value = nil
    }

    func showDetail(_ detail: NavigationDetail) {
        guard detailSubject.value == nil else {
            return
        }

        detailSubject.value = detail
    }
}

extension NavigationDetail? {
    fileprivate var elements: [NavigationElement] {
        if let detail = self {
            [.main, .detail(detail)]
        } else {
            [.main]
        }
    }
}
