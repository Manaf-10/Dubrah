//
//  PortfolioCollectionViewCell.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

class PortfolioCollectionViewCell: UICollectionViewCell {
    
    

    @IBOutlet weak var imgPortfolio: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = true

        imgPortfolio.contentMode = .scaleAspectFill
        imgPortfolio.clipsToBounds = true
        imgPortfolio.layer.cornerRadius = 14
    }

    func setup(with item: PortfolioItem) {
        imgPortfolio.image = item.image
        lblTitle.text = item.title
        lblDate.text = item.date
    }
}
