import Foundation

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
