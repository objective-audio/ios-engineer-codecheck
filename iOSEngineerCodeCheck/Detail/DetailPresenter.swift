import Combine
import Foundation

@MainActor
protocol ImageCacheForPresenter {
    var statePublisher: AnyPublisher<ImageCacheState, Never> { get }
    func load(url: URL)
}

/// Detail画面に必要なデータを変換して提供するクラス

@MainActor
final class DetailPresenter: ObservableObject {
    let repository: GitHubRepository

    @Published var imageContent: DetailImageContent = .message(.loading)

    init(repository: GitHubRepository, imageCache: ImageCacheForPresenter) {
        self.repository = repository

        imageCache.statePublisher.map(\.content).assign(to: &$imageContent)

        if let url = repository.avatarUrl {
            imageCache.load(url: url)
        }
    }
}

extension ImageCacheState {
    fileprivate var content: DetailImageContent {
        switch self {
        case .initial, .loading:
            .message(.loading)
        case let .loaded(image):
            .image(image)
        case .failed:
            .message(.notFound)
        }
    }
}
