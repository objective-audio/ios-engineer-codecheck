import Combine
import Foundation

import class UIKit.UIImage

enum DetailImageContent {
    enum Message {
        case loading
        case notFound
    }

    case image(UIImage)
    case message(Message)
}

@MainActor
protocol ImageCacheForPresenter {
    var statePublisher: AnyPublisher<ImageCacheState, Never> { get }
    func load(url: URL)
}

@MainActor
final class DetailPresenter: ObservableObject {
    let repository: GitHubRepository

    @Published var imageContent: DetailImageContent = .message(.loading)

    private var cancellables: Set<AnyCancellable> = []

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
