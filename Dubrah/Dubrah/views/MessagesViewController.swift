//
//  MessageViewController.swift
//  Dubrah
//
//  Created by Sayed on 23/12/2025.
//


import UIKit
import FirebaseAuth

class MessagesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var tempImage: UIImage?
    var chats: [Chat] = []
    var filteredChats: [Chat] = []
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.separatorStyle = .none
        
        Task { await loadData() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func loadData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let fetched = try await ChatController.shared.getUserChats(userID: uid)
            await MainActor.run {
                self.chats = fetched
                self.tableView.reloadData()
            }
        } catch { print("Error loading chats: \(error)") }
    }

    // MARK: - Search Logic
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if text.isEmpty {
            isSearching = false
            filteredChats.removeAll()
        } else {
            isSearching = true
            filteredChats = chats.filter { chat in
                let nameMatch = chat.userName.lowercased().contains(text.lowercased())
                let lastMsgMatch = chat.messages.last?.content.lowercased().contains(text.lowercased()) ?? false
                return nameMatch || lastMsgMatch
            }
        }
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        Task {
             await loadData()
        }
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredChats.count : chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let item = isSearching ? filteredChats[indexPath.row] : chats[indexPath.row]
        
        cell.nameLabel.text = item.userName
        cell.messageLabel.text = item.messages.last?.content ?? "No messages yet"
        cell.verifiedImage.isHidden = !item.verified
        
        cell.profileImage.image = UIImage(named: "user_icon")
        
        if !item.userImage.isEmpty {
            Task {
                if let image = await ImageDownloader.fetchImage(from: item.userImage) {
                    tempImage = image
                    await MainActor.run {
                        if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                            cell.profileImage.image = image
                        }
                    }
                }
            }
        }
        
        return cell
    }

    // MARK: - Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowChat", sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChat",
           let chatVC = segue.destination as? ChatViewController,
           let indexPath = sender as? IndexPath {
            
            let item = isSearching ? filteredChats[indexPath.row] : chats[indexPath.row]
            chatVC.chatID = item.id
            chatVC.userName = item.userName
            chatVC.userImage = tempImage
            chatVC.isVerified = item.verified
            chatVC.receiverID = item.receiverID
            if let cell = tableView.cellForRow(at: indexPath) as? MessageCell {
                chatVC.userImage = cell.profileImage.image
            }
        }
    }
}
