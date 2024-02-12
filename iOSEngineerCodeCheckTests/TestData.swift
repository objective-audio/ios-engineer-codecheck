import Foundation

import class UIKit.UIImage

final class TestData {
    static var repositoriesJsonData: Data {
        let jsonUrl = Bundle(for: Self.self).url(
            forResource: "github-repositories", withExtension: "json")!
        let json = try! String(contentsOf: jsonUrl, encoding: .utf8)
        return json.data(using: .utf8)!
    }

    static let image: UIImage = .init(systemName: "pencil")!
    static let otherImage: UIImage = .init(systemName: "trash")!
    static let imageUrl: URL = .init(string: "https://example.com/dummy.jpg")!
}
