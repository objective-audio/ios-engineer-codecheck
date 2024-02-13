import Foundation

/// Detail画面で扱う画像キャッシュオブジェクトを生成するクラス
/// テストの時はモックした通信オブジェクトに差し替えて生成します

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
