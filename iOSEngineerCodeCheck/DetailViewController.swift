import SwiftUI

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
