//
//  SettingsTableViewCell.swift
//  Dubrah
//
//  Created by user282253 on 12/19/25.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
   
    
    @IBOutlet weak var Settingslbl: UILabel!
    @IBOutlet weak var imgicons: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpCell(photo: UIImage, Settings: String, ){
        
        imgicons.image = photo
        Settingslbl.text = Settings
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
