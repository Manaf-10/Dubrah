//
//  MessageCell.swift
//  Dubrah
//
//  Created by BP-19-114-03 on 02/12/2025.
//

import UIKit

class MessageCell: UITableViewCell {
    

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 30
        profileImage.clipsToBounds = true
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = false
    }
}
