import Combine
import Foundation

import class UIKit.UIImage

protocol DownloaderForImageCache {
    func download(from url: URL) async throws -> UIImage
}

final class ImageCache: ImageCacheForPresenter {
    private let downloader: DownloaderForImageCache
    private let stateSubject: CurrentValueSubject<ImageCacheState, Never> = .init(.initial)

    var state: ImageCacheState {
        stateSubject.value
    }

    var statePublisher: AnyPublisher<ImageCacheState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var imagePublisher: AnyPublisher<UIImage?, Never> {
        statePublisher.map(\.image).eraseToAnyPublisher()
    }

    init(downloader: DownloaderForImageCache) {
        self.downloader = downloader
    }

    func load(url: URL) {
        guard state.canLoad else { return }

        stateSubject.value = .loading

        Task {
            do {
                let image = try await downloader.download(from: url)
                stateSubject.value = .loaded(image)
            } catch {
                stateSubject.value = .failed(error)
            }
        }
    }
}

@MainActor
final class ImageCacheFactory {
    private let isTest: Bool

    init(isTest: Bool) {
        self.isTest = isTest
    }

    func makeImageCache() -> ImageCache {
        let downloader: DownloaderForImageCache =
            isTest ? ImageDownloaderUITestMock() : ImageDownloader()
        return ImageCache(downloader: downloader)
    }
}
