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
    let imageCache: ImageCacheForPresenter

    @Published var image: UIImage?

    private var cancellables: Set<AnyCancellable> = []

    init(repository: GitHubRepository, imageCache: ImageCacheForPresenter) {
        self.repository = repository
        self.imageCache = imageCache

        imageCache.imagePublisher.sink { [weak self] image in
            self?.image = image
        }.store(in: &cancellables)

        if let url = repository.avatarUrl {
            imageCache.load(url: url)
        }
    }
}
