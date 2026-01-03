//
//  VerifyDocsCollectionViewCell.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 02/01/2026.
//

import UIKit

class VerifyDocsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgDocPhoto: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Container handles rounding + border
        containerView.layer.cornerRadius = 14
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor(named: "PrimaryBlue")?.cgColor
        containerView.layer.masksToBounds = true
        
        // Image fills container (NO rounding here)
        imgDocPhoto.contentMode = .scaleAspectFill
        imgDocPhoto.clipsToBounds = true
    }
    
    func setupCell(document: VerificationDocument) {
        // Check if it's a URL or local image
        if let urlString = document.urlString {
            // Load from Firebase
            Task {
                let image = await ImageDownloader.fetchImage(from: urlString)
                await MainActor.run {
                    self.imgDocPhoto.image = image ?? UIImage(named: "placeholder")
                }
            }
        } else if let imageName = document.imageName {
            // Load local mock image
            imgDocPhoto.image = UIImage(named: imageName)
        } else {
            imgDocPhoto.image = UIImage(named: "placeholder")
        }
    }
}
