import Combine
import UIKit

class MainViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!

    private let searcher: GitHubSearcher = .init()
    private var cancellables: Set<AnyCancellable> = []
    private var repositories: [GitHubRepository] { searcher.state.repositories }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self

        searcher.statePublisher.map(\.repositories).sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
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
        searcher.cancel()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searcher.search(word: searchBar.text ?? "")
    }
}
