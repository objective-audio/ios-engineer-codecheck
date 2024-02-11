import Combine
import UIKit

class MainViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!

    private unowned let router: NavigationRouter
    private unowned let searcher: GitHubSearcher
    private var cancellables: Set<AnyCancellable> = []
    private var repositories: [GitHubRepository] { searcher.state.repositories }

    static func make() -> MainViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(identifier: "Main") { coder in
            MainViewController(
                coder: coder, router: App.shared.router, searcher: App.shared.searcher)
        }
        return main
    }

    required init?(coder: NSCoder, router: NavigationRouter, searcher: GitHubSearcher) {
        self.router = router
        self.searcher = searcher
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self

        searcher.statePublisher.map(\.repositories).sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        router.mainDidAppear()
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
        router.showDetail(.init(repository: repository))
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
