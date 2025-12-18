//
//  CategoryCell.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 18/12/2025.
//

import UIKit

class CategoryCell: UICollectionViewCell{
    
    @IBOutlet weak var iconLabel: UILabel!
    
    override func awakeFromNib() {
         super.awakeFromNib()
         setupStyle()
     }

     private func setupStyle() {
         // Cell appearance
         contentView.layer.cornerRadius = 12
         contentView.layer.masksToBounds = true
         contentView.backgroundColor = UIColor(hex : "#FFFFFF")

         // Label appearance
         iconLabel.textAlignment = .center
         iconLabel.numberOfLines = 1
     }

     func configure(with systemImageName: String) {
         let attachment = NSTextAttachment()
         attachment.image = UIImage(systemName: "folder")

         attachment.bounds = CGRect(
             x: 0,
             y: -4,   // vertical alignment tweak
             width: 60,
             height: 60
         )

         iconLabel.attributedText =
             NSMutableAttributedString(attachment: attachment)
     }
}
