//
//  ServiceCollectionViewCell.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

class ServiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var providerLabel: UILabel!
    @IBOutlet weak var providerAvatar: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
 
    
    override func awakeFromNib() {
         super.awakeFromNib()
         setupUI()
     }

    private func setupUI() {
            backgroundColor = .clear
            contentView.backgroundColor = .clear

            containerView.layer.cornerRadius = 24
            containerView.layer.masksToBounds = true

            serviceImageView.contentMode = .scaleAspectFill
            serviceImageView.clipsToBounds = true

        providerAvatar.layer.cornerRadius = providerAvatar.frame.width / 2
           providerAvatar.clipsToBounds = true
           providerAvatar.contentMode = .scaleAspectFill
           
           
           providerAvatar.layer.borderWidth = 2
        providerAvatar.layer.borderColor = UIColor.primaryBlue.cgColor
        
            descriptionLabel.numberOfLines = 2
        }
    
    
    func setupCell(with service: Service) {
            serviceImageView.image = service.image
            titleLabel.text = service.title
            providerLabel.text = service.provider
        providerAvatar.image = service.avatar
            descriptionLabel.text = service.description
        }
}
