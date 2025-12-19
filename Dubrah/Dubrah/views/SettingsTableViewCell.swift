//
//  SettingsTableViewCell.swift
//  Dubrah
//
//  Created by user282253 on 12/19/25.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var imgicon: UIView!
    
    @IBOutlet weak var btns: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
