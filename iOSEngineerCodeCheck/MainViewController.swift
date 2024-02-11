import Combine
import UIKit

class MainViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!

    private let presenter: MainPresenter
    private let controller: MainController
    private var cancellables: Set<AnyCancellable> = []

    static func make() -> MainViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let main = storyboard.instantiateViewController(identifier: "Main") { coder in
            MainViewController(
                coder: coder,
                presenter: .init(searcher: App.shared.searcher),
                controller: .init(router: App.shared.router, searcher: App.shared.searcher))
        }
        return main
    }

    required init?(coder: NSCoder, presenter: MainPresenter, controller: MainController) {
        self.presenter = presenter
        self.controller = controller
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self

        presenter.contentsPublisher.sink { [weak self] _ in
            self?.tableView.reloadData()
        }.store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controller.didAppear()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.contents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = UITableViewCell()

        if indexPath.row < presenter.contents.count {
            let contents = presenter.contents[indexPath.row]

            var configuration = cell.defaultContentConfiguration()
            configuration.text = contents.fullName
            configuration.secondaryText = contents.language
            cell.contentConfiguration = configuration

            cell.tag = indexPath.row
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller.showDetail(at: indexPath.row)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        controller.cancelSearch()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        controller.search(word: searchBar.text ?? "")
    }
}
