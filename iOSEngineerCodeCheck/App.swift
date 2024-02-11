import Foundation

@MainActor
final class App {
    static let shared: App = .init()

    let router: NavigationRouter = .init()
    let searcher: GitHubSearcher = .init()
}
