//
//  UsersCollectionViewCell.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 02/01/2026.
//

import UIKit

class UsersCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgUserAvatar: UIImageView!
    @IBOutlet weak var avatarBorderView: UIView!
    @IBOutlet weak var UsernameLbl: UILabel!
    @IBOutlet weak var UserRoleLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
        }

    private func setupUI() {
        // Remove white background
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card shape
        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true

        // Optional: card color
        containerView.backgroundColor = UIColor(named: "CardBackground")

        // Avatar
        imgUserAvatar.clipsToBounds = true
        // Avatar image
           imgUserAvatar.clipsToBounds = true
           imgUserAvatar.contentMode = .scaleAspectFill

           // Border
           avatarBorderView.layer.borderWidth = 2
           avatarBorderView.layer.borderColor = UIColor(named: "PrimaryBlue")?.cgColor
           avatarBorderView.clipsToBounds = true
    }

        override func layoutSubviews() {
            super.layoutSubviews()
            imgUserAvatar.layer.cornerRadius = imgUserAvatar.frame.width / 2
              avatarBorderView.layer.cornerRadius = avatarBorderView.frame.width / 2

        }

        func setupCell(with user: User) {
            imgUserAvatar.image = user.avatar
            UsernameLbl.text = user.username
            UserRoleLbl.text = user.role
        }
    }
