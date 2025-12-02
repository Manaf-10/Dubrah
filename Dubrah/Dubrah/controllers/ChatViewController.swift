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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
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
        ChatMessage(text: "Sure! What exactly would you like to know?", isIncoming: true)
    ]

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let msg = messages[indexPath.row]

        if msg.isIncoming {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingCell", for: indexPath) as! IncomingMessageCell
            cell.messageLabel.text = msg.text
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingCell", for: indexPath) as! OutgoingMessageCell
            cell.messageLabel.text = msg.text
            return cell
        }
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
