//
//  IncomingMessageCell.swift
//  Dubrah
//
//  Created by BP-19-114-03 on 02/12/2025.
//

import UIKit

class IncomingMessageCell: UITableViewCell {

    

    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.backgroundColor = UIColor(white: 0.92, alpha: 1)
        messageLabel.numberOfLines = 0
    }
}
