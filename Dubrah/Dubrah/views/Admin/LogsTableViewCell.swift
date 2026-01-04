//
//  LogsTableViewCell.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 17/12/2025.
//

import UIKit

class LogsTableViewCell: UITableViewCell {


    @IBOutlet weak var logActionIcon: UIImageView!
    @IBOutlet weak var lblLogDescription: UILabel!
    @IBOutlet weak var lblLogUsername: UILabel!
    @IBOutlet weak var lblLogTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func setupCell(photo: UIImage, description: String, username: String, timestamp: Date){
        logActionIcon.image = photo
        lblLogDescription.text = description
        lblLogUsername.text = username
        lblLogTime.text = formatTimestamp(timestamp)
        
    }
    
    // a helper function to do the time formating for the log
    func formatTimestamp(_ timestamp: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(timestamp)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM" // e.g. 12 May
            return formatter.string(from: timestamp)
        }
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
