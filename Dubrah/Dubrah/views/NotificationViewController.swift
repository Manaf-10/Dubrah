//
//  HomeViewController.swift
//  Dubrah
//
//  Created by BP-19-114-03 on 19/12/2025.
//

import FirebaseFirestore
import FirebaseAuth
class NotificationViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    struct NotificationSection {
        let title: String?
        var items: [Notification]
    }
    
    var sections: [NotificationSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        Task {
           await loadData()
        }
        
        setupNavigation(title: "Notifications")
        setupStyle()
    }
    
    private func loadData() async {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Task {
                do {
                    let fetchedNotifications = try await NotificationController.shared.getUserNotifications(uid: uid)
                    // Use MainActor to update UI
                    await MainActor.run {
                        self.sections = self.groupNotifications(fetchedNotifications)
                        self.tableView.reloadData()
                    }
                } catch {
                    print("DEBUG: Error loading notifications: \(error)")
                }
            }
        }
    
// MARK: - Grouping Logic
    func groupNotifications(_ notifications: [Notification]) -> [NotificationSection] {
        let now = Date()
        let calendar = Calendar.current

        let justNow = notifications.filter { calendar.isDate($0.createdAt, inSameDayAs: now) }
        
        let last7Days = notifications.filter {
            let days = calendar.dateComponents([.day], from: $0.createdAt, to: now).day ?? 0
            return days >= 1 && days <= 7
        }

        let older = notifications.filter {
            let days = calendar.dateComponents([.day], from: $0.createdAt, to: now).day ?? 0
            return days > 7
        }

        var sections: [NotificationSection] = []
        if !justNow.isEmpty { sections.append(NotificationSection(title: "Just now", items: justNow)) }
        if !last7Days.isEmpty { sections.append(NotificationSection(title: "Last 7 days", items: last7Days)) }
        if !older.isEmpty { sections.append(NotificationSection(title: "Older", items: older)) }

        return sections
    }
    
    // MARK: - Sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        
        let notification = sections[indexPath.section].items[indexPath.row]
        cell.configure(with: notification)
        
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
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let notificationToDelete = sections[indexPath.section].items[indexPath.row]
        
        sections[indexPath.section].items.remove(at: indexPath.row)
        

        let mapToRemove: [String: Any] = [
            "content": notificationToDelete.content,
            "createdAt": Timestamp(date: notificationToDelete.createdAt),
            "senderID": notificationToDelete.senderID
        ]
        
        Firestore.firestore().collection("user").document(uid).updateData([
            "notifications": FieldValue.arrayRemove([mapToRemove])
        ]) { error in
            if let error = error { print("Error removing notification: \(error)") }
        }

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

        
    @objc private func handleRefresh() {
        Task {
            await loadData()
            await MainActor.run {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    override func setupStyle() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
}
