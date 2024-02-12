import Foundation

struct UITestContext: Codable {
    let repositories: [GitHubRepository]
}

extension UITestContext {
    func encodeToJson() -> String? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return .init(decoding: data, as: UTF8.self)
    }

    static func decode(fromJson json: String) -> UITestContext? {
        let decoder = JSONDecoder()
        guard let data = json.data(using: .utf8) else { return nil }
        return try? decoder.decode(UITestContext.self, from: data)
    }
}

extension UITestContext {
    static let environmentKey = "ui_test_context"

    static var environmentValue: UITestContext? {
        guard let json = ProcessInfo.processInfo.environment[UITestContext.environmentKey],
            let context = UITestContext.decode(fromJson: json)
        else {
            return nil
        }
        return context
    }
}
