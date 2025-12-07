//
//  ChatViewController.swift
//  Dubrah
//
//  Created by BP-19-114-03 on 02/12/2025.
//

import UIKit

class ChatViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{
    
    var userName: String?
    var userImage: UIImage?

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        // Do any additional setup after loading the view.
        nameLabel.text = userName
        profileImage.image = userImage
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
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
        cell.setupCell(cell: cell , isComing:msg.isIncoming)
        return cell

    }
    func scrollToBottom() {
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    
    @IBAction func sendButtonTapped(_ sender: UIButton){
        guard let text = inputField.text, !text.isEmpty else {return}
        messages.append(ChatMessage(text: text, isIncoming: false))
        inputField.text = ""
        tableView.reloadData()
        scrollToBottom()

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
