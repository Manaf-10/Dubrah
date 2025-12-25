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
    @IBOutlet weak var verifiedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpStyle()
        
    }
    
    
    
    func setUpStyle() {
        profileImage.layer.cornerRadius = 30
        profileImage.clipsToBounds = true
        contentView.layer.masksToBounds = false
        messageLabel.numberOfLines = 1
        messageLabel.lineBreakMode = .byTruncatingTail
    }
}
