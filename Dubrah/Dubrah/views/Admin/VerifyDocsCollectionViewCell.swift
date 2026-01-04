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
    
    var onImageTapped: ((UIImage) -> Void)?  
     
     override func awakeFromNib() {
         super.awakeFromNib()
         
         backgroundColor = .clear
         contentView.backgroundColor = .clear
         
         containerView.layer.cornerRadius = 14
         containerView.layer.borderWidth = 2
         containerView.layer.borderColor = UIColor(named: "PrimaryBlue")?.cgColor
         containerView.layer.masksToBounds = true
         
         imgDocPhoto.contentMode = .scaleAspectFill
         imgDocPhoto.clipsToBounds = true
         
         // ✅ Make image tappable
         imgDocPhoto.isUserInteractionEnabled = true
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
         imgDocPhoto.addGestureRecognizer(tapGesture)
     }
     
     @objc private func imageTapped() {
         guard let image = imgDocPhoto.image else { return }
         onImageTapped?(image)
     }
     
     func setupCell(document: VerificationDocument) {
         if let urlString = document.urlString {
             imgDocPhoto.loadFromUrl(urlString, placeholder: UIImage(named: "placeholder"))
         } else if let imageName = document.imageName {
             imgDocPhoto.image = UIImage(named: imageName)
         } else {
             imgDocPhoto.image = UIImage(named: "placeholder")
         }
     }
 }
