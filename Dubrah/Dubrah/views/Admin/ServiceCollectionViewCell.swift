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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        providerAvatar.layer.cornerRadius = providerAvatar.frame.width / 2
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.layer.cornerRadius = 24
        containerView.layer.masksToBounds = true

        serviceImageView.contentMode = .scaleAspectFill
        serviceImageView.clipsToBounds = true

        providerAvatar.clipsToBounds = true
        providerAvatar.contentMode = .scaleAspectFill
        providerAvatar.layer.borderWidth = 2
        providerAvatar.layer.borderColor = UIColor.primaryBlue.cgColor
        
        titleLabel.numberOfLines = 2
        descriptionLabel.numberOfLines = 2
    }
    
    func setupCell(with service: Service) {
        titleLabel.text = service.title
        providerLabel.text = service.providerName ?? "Loading..."
        descriptionLabel.text = service.description
        
        // Load service image
        serviceImageView.loadFromUrl(service.image)
        
        // Load provider avatar
        if let avatarUrl = service.providerAvatar {
            providerAvatar.loadFromUrl(avatarUrl)
        } else {
            providerAvatar.image = UIImage(named: "Log-Profile")
        }
    }
}
