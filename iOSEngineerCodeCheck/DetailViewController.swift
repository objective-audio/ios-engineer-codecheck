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
    let imageDownloader: ImageDownloader = .init()

    static func make(repository: GitHubRepository) -> DetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detail = storyboard.instantiateViewController(identifier: "Detail") { coder in
            DetailViewController(coder: coder, repository: repository)
        }
        return detail
    }

    required init?(coder: NSCoder, repository: GitHubRepository) {
        self.repository = repository
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

        getImage()
    }

    func getImage() {
        if let urlString = repository.owner?.avatarUrl, let url = URL(string: urlString) {
            Task {
                self.imageView.image = try await imageDownloader.download(from: url)
            }
        }
    }
}
