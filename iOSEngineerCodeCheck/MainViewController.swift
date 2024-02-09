import UIKit

class MainViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!

    var repositories: [GitHubRepository] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    let githubAPIClient: GitHubAPIClient = .init()
    var task: Task<Void, Error>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = UITableViewCell()

        if indexPath.row < repositories.count {
            let repository = repositories[indexPath.row]
            cell.textLabel?.text = repository.fullName
            cell.detailTextLabel?.text = repository.language
            cell.tag = indexPath.row
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < repositories.count else { return }

        let repository = repositories[indexPath.row]
        let detail = DetailViewController.make(repository: repository)
        navigationController?.pushViewController(detail, animated: true)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        task?.cancel()
        task = nil
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let word = searchBar.text ?? ""

        if word.count > 0 {
            task = Task {
                self.repositories = try await githubAPIClient.fetchRepositories(word: word)
            }
        }
    }
}
