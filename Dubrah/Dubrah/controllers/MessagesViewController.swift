import UIKit

class MessagesViewController: UIViewController,
                             UITableViewDelegate,
                             UITableViewDataSource,
                             UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    struct MessagePreview {
        let name: String
        let message: String
        let verified: Bool
    }

    // MARK: - Data
    var messages: [MessagePreview] = [
        MessagePreview(name: "Michael",
                       message: "You: Tuesday sounds perfect! For a group of six.",
                       verified: true),

        MessagePreview(name: "Luca",
                       message: "Luca: Yes, however highlights will hike the price.",
                       verified: false),

        MessagePreview(name: "Christopher",
                       message: "You: Thanks again! My daughter loved her mural.",
                       verified: true)
    ]

    var filteredMessages: [MessagePreview] = []
    var isSearching = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        searchBar.delegate = self
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredMessages.count : messages.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MessageCell",
            for: indexPath
        ) as! MessageCell

        let item = isSearching
            ? filteredMessages[indexPath.row]
            : messages[indexPath.row]

        cell.profileImage.image = UIImage(named: "user_icon")
        cell.nameLabel.text = item.name
        cell.messageLabel.text = item.message
        cell.verifiedImage.isHidden = !item.verified

        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        // Trigger storyboard segue ONLY
        performSegue(withIdentifier: "ShowChat", sender: indexPath)
    }

    // MARK: - Navigation (PASS DATA HERE)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChat",
           let chatVC = segue.destination as? ChatViewController,
           let indexPath = sender as? IndexPath {

            let item = isSearching
                ? filteredMessages[indexPath.row]
                : messages[indexPath.row]

            chatVC.userName = item.name
        }
    }

    // MARK: - SearchBar Logic
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            isSearching = false
            filteredMessages.removeAll()
        } else {
            isSearching = true
            filteredMessages = messages.filter {
                $0.name.lowercased().contains(text.lowercased()) ||
                $0.message.lowercased().contains(text.lowercased())
            }
        }

        tableView.reloadData()
    }
}
