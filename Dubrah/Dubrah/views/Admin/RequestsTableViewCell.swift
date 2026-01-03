//
//  RequestsTableViewCell.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 23/12/2025.
//

import UIKit

class RequestsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgUserPhoto: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblUserRole: UILabel!
    @IBOutlet weak var btnViewRequest: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(photo: UIImage, name: String, role: String) {
        imgUserPhoto.image = photo
        lblUsername.text = name
        lblUserRole.text = role
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
