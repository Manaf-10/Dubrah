import UIKit

class NotificationPage: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    struct NotificationMessage {
        let text: String
    }

    var notifications: [NotificationMessage] = [
        NotificationMessage(text: "Ahmed sent you a new message"),
        NotificationMessage(text: "You have a missed call from Sara"),
        NotificationMessage(text: "Your verification was successful"),
        NotificationMessage(text: "New friend request from Khalid"),
        NotificationMessage(text: "You received a new voice note"),
        NotificationMessage(text: "Your profile photo was updated"),
        NotificationMessage(text: "Fatima mentioned you in a message"),
        NotificationMessage(text: "Security alert: New login detected"),
        NotificationMessage(text: "You have unread messages")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        // Custom back button
        let backButton = UIButton(type: .system)
        backButton.setTitle("← Notifications", for: .normal)
        backButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "NotificationCell",
            for: indexPath
        ) as! NotificationCell
        let msg = notifications[indexPath.row]
        cell.notificationLabel.text = msg.text

        return cell
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Notification tapped", indexPath.row)
    }
}
