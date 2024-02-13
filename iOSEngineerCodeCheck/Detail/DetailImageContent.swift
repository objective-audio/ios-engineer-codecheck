import Foundation

import class UIKit.UIImage

enum DetailImageContent {
    enum Message {
        case loading
        case notFound
    }

    case image(UIImage)
    case message(Message)
}
