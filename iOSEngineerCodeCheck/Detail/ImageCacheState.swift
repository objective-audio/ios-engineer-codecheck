import Foundation

import class UIKit.UIImage

enum ImageCacheState {
    case initial
    case loading
    case loaded(UIImage)
    case failed(Error)
}

extension ImageCacheState {
    var image: UIImage? {
        switch self {
        case let .loaded(image):
            image
        case .initial, .loading, .failed:
            nil
        }
    }

    var canLoad: Bool {
        switch self {
        case .initial, .failed:
            return true
        case .loading, .loaded:
            return false
        }
    }
}
