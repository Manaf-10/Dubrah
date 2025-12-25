//
//  ChatViewController.swift
//  Dubrah
//
//  Created by BP-19-114-03 on 02/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var navigationContainer: UIStackView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var pageContainer: UIStackView!
    
    // MARK: - Properties
    var chatID: String?
    var userName: String?
    var isVerified: Bool = false
    var userImage: UIImage?
    var messages: [Message] = []
    var listener: ListenerRegistration?
    var receiverID: String?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.image = userImage ?? UIImage(named: "user_icon")
        setupStyle()
        
        startListening()
        
        pageContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10)
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Setup
    override func setupStyle() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        inputField.delegate = self
        sendButton.isEnabled = false
        navigationContainer.backgroundColor = UIColor(hex: "#F8FAFC")
        tableView.backgroundColor = UIColor(hex: "#F8FAFC")
        self.navigationController?.isNavigationBarHidden = true
        profileImage.layer.cornerRadius = 20
        
        let attributedText = NSMutableAttributedString()
        let tempName = userName ?? "Unknown"
        let name = NSAttributedString(string: tempName + " ", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(hex:"#353E5C")
        ])
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "verified")
        attachment.bounds = CGRect(x: 0, y: -1, width: 14, height: 14)
        attributedText.append(name)
        if(isVerified){attributedText.append(NSAttributedString(attachment: attachment))}
        nameLabel.attributedText = attributedText
        tableView.keyboardDismissMode = .interactive
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false // This ensures the table cells still work
        view.addGestureRecognizer(tap)
    }

    
    // MARK: - Backend Interaction
    func startListening() {
        guard let id = chatID else { return }
        
        listener = ChatController.shared.observeMessages(chatID: id) { [weak self] newMessages in
            self?.messages = newMessages
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.scrollToBottom()
            }
        }
    }
    
    @IBAction func valueChanged(_ sender: UITextField) {
        let text = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        sendButton.isEnabled = !text.isEmpty
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let text = inputField.text, !text.isEmpty,
              let id = chatID,
              let uid = Auth.auth().currentUser?.uid else { return }
        
        let content = text
        inputField.text = ""
        sendButton.isEnabled = false
        
        Task {
            do {
                let uid = Auth.auth().currentUser!.uid
                try await ChatController.shared.sendMessage(chatID: id, senderID: uid, content: content)
                try await NotificationController.shared.newNotification(receiverId: receiverID ?? "", senderId: uid, type: .message)
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView Logic
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! NewMessageTableViewCell
        let msg = messages[indexPath.row]
        
        cell.messageLabel.text = msg.content
        cell.setupCell(isComing: msg.isIncoming)
        
        return cell
    }
    
    func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}
