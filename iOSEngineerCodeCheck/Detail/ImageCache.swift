import Combine
import Foundation

import class UIKit.UIImage

protocol DownloaderForImageCache {
    func download(from url: URL) async throws -> UIImage
}

/// Detail画面で表示する画像を取得して保持する
/// 非同期の通信をラップして、データの取得状態をプロパティで取得できるようにしています

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
