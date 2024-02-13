import Foundation

import class UIKit.UIImage

/// Viewの画像部分のデータ

enum DetailImageContent {
    enum Message {
        case loading
        case notFound
    }

    case image(UIImage)
    case message(Message)
}
