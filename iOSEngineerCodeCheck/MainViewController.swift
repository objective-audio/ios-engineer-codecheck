import UIKit

class MainViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!

    var repositories: [GitHubRepository] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var task: URLSessionTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.placeholder = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        task?.cancel()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let word = searchBar.text ?? ""

        if word.count > 0 {
            guard let url = URL(string: "https://api.github.com/search/repositories?q=\(word)")
            else {
                return
            }
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
                guard let data else { return }

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                guard let repositories = try? decoder.decode(GitHubRepositories.self, from: data)
                else {
                    return
                }

                DispatchQueue.main.async {
                    self?.repositories = repositories.items ?? []
                }
            }
            self.task = task
            // これ呼ばなきゃリストが更新されません
            task.resume()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = UITableViewCell()
        let repository = repositories[indexPath.row]
        cell.textLabel?.text = repository.fullName
        cell.detailTextLabel?.text = repository.language
        cell.tag = indexPath.row
        return cell

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repository = repositories[indexPath.row]
        let detail = DetailViewController.make(repository: repository)
        navigationController?.pushViewController(detail, animated: true)
    }
}
