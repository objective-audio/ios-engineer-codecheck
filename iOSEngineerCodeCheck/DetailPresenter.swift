import Combine
import Foundation

import class UIKit.UIImage

@MainActor
protocol ImageCacheForPresenter {
    var imagePublisher: AnyPublisher<UIImage?, Never> { get }
    func load(url: URL)
}

@MainActor
final class DetailPresenter: ObservableObject {
    let repository: GitHubRepository

    @Published var image: UIImage?

    private var cancellables: Set<AnyCancellable> = []

    init(repository: GitHubRepository, imageCache: ImageCacheForPresenter) {
        self.repository = repository

        imageCache.imagePublisher.assign(to: &$image)

        if let url = repository.avatarUrl {
            imageCache.load(url: url)
        }
    }
}
