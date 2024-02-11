import Foundation

import class UIKit.UIImage

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
