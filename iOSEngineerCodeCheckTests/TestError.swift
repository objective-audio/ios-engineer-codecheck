import Foundation

import class UIKit.UIImage

enum TestError: Error {
    case dummy
}

let testImage: UIImage = .init(systemName: "pencil")!
let testOtherImage: UIImage = .init(systemName: "trash")!
let testImageUrl: URL = .init(string: "https://example.com/dummy.jpg")!
