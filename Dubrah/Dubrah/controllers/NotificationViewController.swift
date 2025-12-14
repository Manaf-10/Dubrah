import UIKit

class NotificationPage: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    struct NotificationMessage {
        let text: String
        let date: Date
    }

    struct NotificationSection {
        let title: String?
        var items: [NotificationMessage]
    }
    
    func groupNotifications(_ notifications: [NotificationMessage]) -> [NotificationSection] {
           let now = Date()
           let calendar = Calendar.current

           let justNow = notifications.filter {
               calendar.isDate($0.date, equalTo: now, toGranularity: .day)
           }

           let last7Days = notifications.filter {
               guard let days = calendar.dateComponents([.day], from: $0.date, to: now).day else { return false }
               return days >= 1 && days <= 7
           }

           let lastMonth = notifications.filter {
               guard let months = calendar.dateComponents([.month], from: $0.date, to: now).month else { return false }
               return months == 1
           }

           let older = notifications.filter {
               guard let months = calendar.dateComponents([.month], from: $0.date, to: now).month else { return false }
               return months >= 2
           }

           var sections: [NotificationSection] = []

           if !justNow.isEmpty {
               sections.append(NotificationSection(title: "Just now", items: justNow))
           }
           if !last7Days.isEmpty {
               sections.append(NotificationSection(title: "Last 7 days", items: last7Days))
           }
           if !lastMonth.isEmpty {
               sections.append(NotificationSection(title: "Last month", items: lastMonth))
           }
           if !older.isEmpty {
               sections.append(NotificationSection(title: nil, items: older))
           }

           return sections
       }

    

    var notifications: [NotificationMessage] = [
        NotificationMessage(text: "Alex received three 5-star reviews this week! Check out more.", date: Date()),
        NotificationMessage(text: "You have a new message from Luca.", date: Date().addingTimeInterval(-60 * 30)),
        NotificationMessage(text: "Your review helped 18 people this week!", date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
        NotificationMessage(text: "Fatima replied to your review.", date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!),
        NotificationMessage(text: "You received a thank-you message from Christopher.", date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
        NotificationMessage(text: "Luca liked your review.", date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
        NotificationMessage(text: "Your account was successfully verified.", date: Calendar.current.date(byAdding: .month, value: -2, to: Date())!),
        NotificationMessage(text: "Security alert: New login detected.", date: Calendar.current.date(byAdding: .month, value: -4, to: Date())!)
    ]

    var sections: [NotificationSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        

        sections = groupNotifications(notifications)

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

    // MARK: - Sections

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "NotificationCell",
            for: indexPath
        ) as! NotificationCell

        let msg = sections[indexPath.section].items[indexPath.row]
        cell.notificationLabel.text = msg.text

        return cell
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].title == nil ? 0 : 40
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        guard editingStyle == .delete else { return }

        
        sections[indexPath.section].items.remove(at: indexPath.row)

        
        if sections[indexPath.section].items.isEmpty {
            sections.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        } else {
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int) {

        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .black
        }
    }


}
