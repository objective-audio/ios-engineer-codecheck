import UIKit

class MainViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!

    var repositories: [[String: Any]] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var task: URLSessionTask?
    var selectedIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.text = "GitHubのリポジトリを検索できるよー"
        searchBar.delegate = self
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // ↓こうすれば初期のテキストを消せる
        searchBar.text = ""
        return true
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
            let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
                guard let data,
                    let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let items = object["items"] as? [[String: Any]]
                else {
                    return
                }
                DispatchQueue.main.async {
                    self.repositories = items
                }
            }
            self.task = task
            // これ呼ばなきゃリストが更新されません
            task.resume()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Detail" {
            let detail = segue.destination as! DetailViewController
            detail.mainVC = self
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
        cell.textLabel?.text = repository["full_name"] as? String ?? ""
        cell.detailTextLabel?.text = repository["language"] as? String ?? ""
        cell.tag = indexPath.row
        return cell

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 画面遷移時に呼ばれる
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "Detail", sender: self)
    }
}
