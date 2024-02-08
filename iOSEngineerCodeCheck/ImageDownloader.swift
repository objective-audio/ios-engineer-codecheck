import Foundation

import class UIKit.UIImage

final class ImageDownloader {
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
