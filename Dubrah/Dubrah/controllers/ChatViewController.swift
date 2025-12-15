//
//  ChatViewController.swift
//  Dubrah
//
//  Created by BP-19-114-03 on 02/12/2025.
//

import UIKit

class ChatViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    var userName: String?
    var userImage: UIImage?
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var inputTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    @IBAction func valueChanged(_ sender: UITextField) {
        sendButton.isEnabled = !(sender.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
    func setupNavBarTitle() {
        let container = UIStackView()
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 8

        // Profile Image
        let imageView = UIImageView()
        imageView.image = userImage ?? UIImage(named: "user_icon")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Name Label
        let nameLabel = UILabel()
        nameLabel.text = userName
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .label

        container.addArrangedSubview(imageView)
        container.addArrangedSubview(nameLabel)

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = userName
        inputField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        setupNavBarTitle()
//      tableHeight.isActive = false
        tableHeight.constant = 350
        inputTopConstraint.constant = -50
    }
    
    struct ChatMessage {
        let text: String
        let isIncoming: Bool
    }

    
    var messages: [ChatMessage] = [
        ChatMessage(text: "Hello! How can I help you today?", isIncoming: true),
        ChatMessage(text: "I want to know more about your services.", isIncoming: false),
        ChatMessage(text: "Sure! What exactly would you like to know?", isIncoming: true),
        ChatMessage(text: "Hello! How can I help you today?", isIncoming: true),
        ChatMessage(text: "I want to know more about your services.", isIncoming: false),
        ChatMessage(text: "Sure! What exactly would you like to know?", isIncoming: true),
        ChatMessage(text: "Hello! How can I help you today?", isIncoming: true),
        ChatMessage(text: "I want to know more about your services.", isIncoming: false),
        ChatMessage(text: "Sure! What exactly would you like to know?", isIncoming: true)
    ]

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! NewMessageTableViewCell
        
        //Initialize MessageCell
        //get each message from the messages array
        //assign to text label based on isIncoming value from each message in the array
        //return cell in each if statement block
        
        let msg = messages[indexPath.row]
        cell.messageLabel.text = msg.text
        cell.setupCell(isComing:msg.isIncoming)
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func scrollToBottom() {
        guard messages.count > 0 else { return }

        let lastRow = messages.count - 1
        let indexPath = IndexPath(row: lastRow, section: 0)

        if tableView.numberOfRows(inSection: 0) > lastRow {
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }


    
    @IBAction func sendButtonTapped(_ sender: UIButton){
        guard let text = inputField.text, !text.isEmpty else {return}
        messages.append(ChatMessage(text: text, isIncoming: false))
        inputField.text = ""
        tableView.reloadData()
        DispatchQueue.main.async {
            self.scrollToBottom()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Force keyboard to close
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            inputTopConstraint.constant = 0
            tableHeight.constant = 0
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
