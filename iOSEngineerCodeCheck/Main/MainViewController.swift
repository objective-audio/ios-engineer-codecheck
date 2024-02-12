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

        presenter.contentPublisher.sink { [weak self] _ in
            self?.tableView.reloadData()
            self?.updateTitle()
        }.store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        controller.didAppear()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.content.cellContents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = UITableViewCell()

        let cellContents = presenter.content.cellContents
        if indexPath.row < cellContents.count {
            let cellContent = cellContents[indexPath.row]

            var configuration = cell.defaultContentConfiguration()
            configuration.text = cellContent.fullName
            configuration.secondaryText = cellContent.language
            cell.contentConfiguration = configuration

            cell.tag = indexPath.row
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller.showDetail(at: indexPath.row)
    }

    private func updateTitle() {
        title = presenter.content.message.text
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

extension MainMessage {
    fileprivate var text: String? {
        switch self {
        case .waiting:
            "Search GitHub Repository"
        case .loading:
            "Loading..."
        case .failed:
            "Load failed"
        case .loaded:
            "Loaded"
        case .cancelled:
            "Cancelled"
        }
    }
}