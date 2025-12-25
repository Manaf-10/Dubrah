//
//  NewMessageTableViewCell.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 07/12/2025.
//

import UIKit

class NewMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint?
    @IBOutlet weak var containerView: UIView!
    
    private var maxWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.numberOfLines = 0
        maxWidthConstraint = bubbleView.widthAnchor.constraint(
               lessThanOrEqualTo: containerView.widthAnchor,
               multiplier: 0.7
           )
        maxWidthConstraint.isActive = true
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupCell(isComing: Bool) {
        if isComing {
            
            leadingConstraint?.isActive = true
            bubbleView.backgroundColor = UIColor(hex: "#E9E9EB")
            messageLabel.textColor = .black
        } else {
            leadingConstraint?.isActive = false
            trailingConstraint?.isActive = true
            bubbleView.backgroundColor = UIColor(hex: "#1D8BFE")
            messageLabel.textColor = .white

        }
    }
}
