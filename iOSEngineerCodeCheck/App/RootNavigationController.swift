import Combine
import UIKit

/// ナビゲーション遷移を行う画面
/// ナビゲーションの子要素から遷移を行うのは簡単ではあるものの正しくないので、UINavigationControllerのサブクラスで実装して、遷移のみをここで管理します

class RootNavigationController: UINavigationController {
    private unowned let router: NavigationRouter = App.shared.router
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        router.elementsPublisher.removeDuplicates().sink { [weak self] _ in
            self?.updateViewControllers()
        }.store(in: &cancellables)
    }

    private func updateViewControllers() {
        let elements = router.elements
        let previousCount = viewControllers.count

        // モデル（NavigationRouter）で保持している配列の変更に合わせて、UIに表示する要素を反映します
        // 本来は各要素にIDを持たせて一致するかも確認して更新すべきですが、とりあえず要素数だけ見ています
        // 多分SwiftUIのNavigationStackを使うとシンプルにやりたいことが実現できそうです
        if elements.count < previousCount {
            setViewControllers(
                Array(viewControllers.prefix(elements.count)), animated: true)
        } else if previousCount < elements.count {
            var viewControllers = viewControllers
            for index in previousCount..<elements.count {
                let viewController =
                    makeViewController(element: elements[index]) ?? UIViewController()
                viewControllers.append(viewController)
            }
            setViewControllers(viewControllers, animated: true)
        }
    }

    private func makeViewController(element: NavigationElement) -> UIViewController? {
        switch element {
        case .main:
            MainViewController.make()
        case let .detail(repositoryIndex):
            DetailViewController.make(repositoryIndex: repositoryIndex)
        }
    }
}
