import Foundation

/// アプリ全体で扱うオブジェクトを保持するクラス
/// アプリで唯一存在するシングルトン
/// UIテストで実行される時には、各オブジェクトにモックするデータを渡せるようにしています

@MainActor
final class App {
    static let shared: App = .init(uiTestContext: .environmentValue)

    private let uiTestContext: UITestContext?
    let imageCacheFactory: ImageCacheFactory
    let router: NavigationRouter
    let searcher: GitHubSearcher

    init(uiTestContext: UITestContext?) {
        self.uiTestContext = uiTestContext

        let imageCacheFactory = ImageCacheFactory(isTest: uiTestContext != nil)
        self.imageCacheFactory = imageCacheFactory

        router = .init(imageCacheFactory: imageCacheFactory)

        if let uiTestContext {
            self.searcher = .init(
                apiClient: GitHubAPIClientUITestMock(result: .success(uiTestContext.repositories)))
        } else {
            self.searcher = .init(apiClient: GitHubAPIClient())
        }
    }

    var detail: Detail? {
        guard case let .detail(detail) = router.state else { return nil }
        return detail
    }
}
