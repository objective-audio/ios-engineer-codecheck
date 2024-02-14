import Combine
import SwiftUI

/// 個別のGitHubリポジトリの詳細を表示するDetail画面

struct DetailView: View {
    @ObservedObject var presenter: DetailPresenter
    var repository: GitHubRepository { presenter.repository }

    var body: some View {
        List {
            Group {
                switch presenter.imageContent {
                case let .image(image):
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                case let .message(message):
                    ZStack {
                        Color(uiColor: .quaternarySystemFill)
                            .aspectRatio(1.0, contentMode: .fill)
                        Text(message.text)
                            .foregroundStyle(.tertiary)
                            .layoutPriority(-1)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .padding(.bottom)
            Text(repository.fullName ?? "")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .padding(.vertical)
            HStack {
                VStack {
                    Text(Localized.Detail.language(repository.language ?? ""))
                        .font(.headline)
                    Spacer()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 16) {
                    Text(Localized.Detail.starsCount(repository.stargazersCount ?? 0))
                        .font(.subheadline)
                    Text(Localized.Detail.watchersCount(repository.watchersCount ?? 0))
                        .font(.subheadline)
                    Text(Localized.Detail.forksCount(repository.forksCount ?? 0))
                        .font(.subheadline)
                    Text(Localized.Detail.openIssuesCount(repository.openIssuesCount ?? 0))
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

extension DetailImageContent.Message {
    fileprivate var text: String {
        switch self {
        case .loading:
            "Loading..."
        case .notFound:
            "Not Found"
        }
    }
}

private final class PreviewImageCache: ImageCacheForPresenter {
    var statePublisher: AnyPublisher<ImageCacheState, Never> {
        Just(.loaded(UIImage(systemName: "eraser")!)).eraseToAnyPublisher()
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
