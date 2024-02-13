import Foundation

import class UIKit.UIImage

/// 画像取得の通信を行うクラス
/// 通信処理をラップし、UIImageに変換して返します

actor ImageDownloader: DownloaderForImageCache {
    enum DownloadError: Error {
        case dataConvertFailed
    }

    func download(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)

        guard let image = UIImage(data: data) else {
            throw DownloadError.dataConvertFailed
        }

        return image
    }
}

actor ImageDownloaderUITestMock: DownloaderForImageCache {
    enum DownloadError: Error {
        case makeImageFailed
    }

    func download(from url: URL) async throws -> UIImage {
        guard let image = UIImage(systemName: url.lastPathComponent) else {
            throw DownloadError.makeImageFailed
        }
        return image
    }
}
