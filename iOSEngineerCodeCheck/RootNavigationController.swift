import Combine
import UIKit

class RootNavigationController: UINavigationController {
    private let router: NavigationRouter = .init()
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        router.elementsPublisher.sink { [weak self] _ in
            self?.updateViewControllers()
        }.store(in: &cancellables)
    }

    private func updateViewControllers() {
        let elements = router.elements
        let previousCount = viewControllers.count

        if elements.count < previousCount {
            setViewControllers(
                Array(viewControllers.prefix(elements.count)), animated: true)
        } else if previousCount < elements.count {
            var viewControllers = viewControllers
            for index in previousCount..<elements.count {
                let viewController = makeViewController(element: elements[index])
                viewControllers.append(viewController)
            }
            setViewControllers(viewControllers, animated: true)
        }
    }

    private func makeViewController(element: NavigationElement) -> UIViewController {
        switch element {
        case .main:
            MainViewController.make(router: router)
        case let .detail(detail):
            DetailViewController.make(repository: detail.repository)
        }
    }
}
