import SwiftUI

/// 個別のGitHubリポジトリの詳細を表示するDetail画面
/// 中身はSwiftUIで実装しているので、生成処理のみ

class DetailViewController: UIHostingController<DetailView> {
    static func make(repositoryIndex: Int) -> DetailViewController? {
        let repositories = App.shared.searcher.state.repositories

        guard let detail = App.shared.detail, detail.repositoryIndex == repositoryIndex,
            repositoryIndex < repositories.count
        else { return nil }

        let presenter = DetailPresenter(
            repository: repositories[repositoryIndex], imageCache: detail.imageCache)

        return .init(rootView: .init(presenter: presenter))
    }
}
