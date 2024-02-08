import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    @IBOutlet weak var watchersLabel: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var issuesLabel: UILabel!

    var mainVC: MainViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let repository = mainVC.repositories[mainVC.selectedIndex]

        languageLabel.text = "Written in \(repository["language"] as? String ?? "")"
        starsLabel.text = "\(repository["stargazers_count"] as? Int ?? 0) stars"
        watchersLabel.text = "\(repository["wachers_count"] as? Int ?? 0) watchers"
        forksLabel.text = "\(repository["forks_count"] as? Int ?? 0) forks"
        issuesLabel.text = "\(repository["open_issues_count"] as? Int ?? 0) open issues"
        getImage()
    }

    func getImage() {
        let repository = mainVC.repositories[mainVC.selectedIndex]

        titleLabel.text = repository["full_name"] as? String

        if let owner = repository["owner"] as? [String: Any] {
            if let urlString = owner["avatar_url"] as? String, let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { (data, _, _) in
                    guard let data, let image = UIImage(data: data) else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }.resume()
            }
        }
    }
}
