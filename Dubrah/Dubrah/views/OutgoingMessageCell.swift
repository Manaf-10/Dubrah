//
//  OutgoingMessageCell.swift
//  Dubrah
//
//  Created by BP-19-114-03 on 02/12/2025.
//

import UIKit

class OutgoingMessageCell: UITableViewCell {

    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.backgroundColor = UIColor.systemBlue
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
    }
}

