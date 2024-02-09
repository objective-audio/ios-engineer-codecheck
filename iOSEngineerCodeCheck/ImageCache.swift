import Combine
import Foundation

import class UIKit.UIImage

protocol DownloaderForImageCache {
    func download(from url: URL) async throws -> UIImage
}

@MainActor
final class ImageCache {
    private let downloader: DownloaderForImageCache
    private let stateSubject: CurrentValueSubject<ImageCacheState, Never> = .init(.initial)

    var state: ImageCacheState {
        stateSubject.value
    }

    var statePublisher: AnyPublisher<ImageCacheState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    init(downloader: DownloaderForImageCache = ImageDownloader()) {
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
