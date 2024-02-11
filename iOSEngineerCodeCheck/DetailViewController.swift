import SwiftUI

class DetailViewController: UIHostingController<DetailView> {
    static func make(repositoryIndex: Int) -> DetailViewController? {
        let repositories = App.shared.searcher.state.repositories

        guard repositoryIndex < repositories.count else { return nil }

        let imageCache = App.shared.makeImageCache()
        let presenter = DetailPresenter(
            repository: repositories[repositoryIndex], imageCache: imageCache)

        return .init(rootView: .init(presenter: presenter))
    }
}
