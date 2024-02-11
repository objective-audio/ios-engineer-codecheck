import Combine
import SwiftUI

struct DetailView: View {
    @ObservedObject var presenter: DetailPresenter
    var repository: GitHubRepository { presenter.repository }

    var body: some View {
        List {
            if let image = presenter.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .listRowSeparator(.hidden)
                    .padding(.bottom)
            }
            Text(repository.fullName ?? "")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .padding(.vertical)
            HStack {
                VStack {
                    Text("Written in \(repository.language ?? "")")
                        .font(.headline)
                    Spacer()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 16) {
                    Text("\(repository.stargazersCount ?? 0) stars")
                        .font(.subheadline)
                    Text("\(repository.watchersCount ?? 0) watchers")
                        .font(.subheadline)
                    Text("\(repository.forksCount ?? 0) forks")
                        .font(.subheadline)
                    Text("\(repository.openIssuesCount ?? 0) open issues")
                        .font(.subheadline)
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .frame(maxWidth: 600)
    }
}

private final class PreviewImageCache: ImageCacheForPresenter {
    var imagePublisher: AnyPublisher<UIImage?, Never> {
        Just(UIImage(systemName: "eraser")).eraseToAnyPublisher()
    }
    func load(url: URL) {}
}

#Preview {
    DetailView(
        presenter: .init(
            repository: .init(
                fullName: "full-name", language: "Swift", owner: .init(avatarUrl: nil),
                stargazersCount: 1, watchersCount: 2, forksCount: 3, openIssuesCount: 4),
            imageCache: PreviewImageCache())
    )
}
