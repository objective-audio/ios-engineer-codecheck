import Combine
import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var issuesLabel: UILabel!

    let repository: GitHubRepository
    let imageCache: ImageCache

    private var cancellables: Set<AnyCancellable> = []

    static func make(repository: GitHubRepository) -> DetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detail = storyboard.instantiateViewController(identifier: "Detail") { coder in
            DetailViewController(coder: coder, repository: repository)
        }
        return detail
    }

    required init?(coder: NSCoder, repository: GitHubRepository) {
        self.repository = repository
        imageCache = .init()
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        languageLabel.text = "Written in \(repository.language ?? "")"
        starsLabel.text = "\(repository.stargazersCount ?? 0) stars"
        watchersLabel.text = "\(repository.watchersCount ?? 0) watchers"
        forksLabel.text = "\(repository.forksCount ?? 0) forks"
        issuesLabel.text = "\(repository.openIssuesCount ?? 0) open issues"
        titleLabel.text = repository.fullName

        imageCache.statePublisher.map(\.image).removeDuplicates().sink { [weak self] image in
            self?.imageView.image = image
        }.store(in: &cancellables)

        if let url = repository.avatarUrl {
            imageCache.load(url: url)
        }
    }
}
