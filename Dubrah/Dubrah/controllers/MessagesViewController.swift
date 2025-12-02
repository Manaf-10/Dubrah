import UIKit

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
            
    struct MessagePreview {
        let name: String
        let photo: UIImage
        let message: String
        let verified: Bool
    }

    var messages: [MessagePreview] = [
        MessagePreview(name: "Michael",
                       photo: UIImage(named: "Rounded")!,
                       message: "You: Tuesday sounds perfect! For a group of six.",
                       verified: true),

        MessagePreview(name: "Luca",
                       photo: UIImage(named: "Rounded")!,
                       message: "Luca: Yes, however highlights will hike the price.",
                       verified: true),

        MessagePreview(name: "Christopher",
                       photo: UIImage(named: "Rounded")!,
                       message: "You: Thanks again! My daughter loved her mural.",
                       verified: true),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell

        let item = messages[indexPath.row]
        cell.profileImage.image = item.photo
        cell.nameLabel.text = item.name
        cell.messageLabel.text = item.message
        return cell
    }
}
