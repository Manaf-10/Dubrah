//
//  NewMessageTableViewCell.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 07/12/2025.
//

import UIKit

class NewMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var incomingBubble: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(cell: UITableViewCell , isComing: Bool) {
        //style
        if isComing{
            cell.contentView.backgroundColor = .blue
        }
        else{
            cell.contentView.backgroundColor = .red
        }
    }
}
