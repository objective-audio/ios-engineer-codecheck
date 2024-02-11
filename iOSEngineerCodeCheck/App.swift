import Foundation

@MainActor
final class App {
    static let shared: App = .init(uiTestContext: .environmentValue)

    private let uiTestContext: UITestContext?
    let router: NavigationRouter = .init()
    let searcher: GitHubSearcher

    init(uiTestContext: UITestContext?) {
        self.uiTestContext = uiTestContext

        if let uiTestContext {
            self.searcher = .init(
                apiClient: GitHubAPIClientUITestMock(result: .success(uiTestContext.repositories)))
        } else {
            self.searcher = .init(apiClient: GitHubAPIClient())
        }
    }

    func makeImageCache() -> ImageCache {
        let downloader: DownloaderForImageCache =
            App.shared.uiTestContext == nil ? ImageDownloader() : ImageDownloaderUITestMock()
        return ImageCache(downloader: downloader)
    }
}
