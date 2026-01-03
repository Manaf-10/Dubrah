//
//  TimeCollectionViewCell.swift
//  Dubrah
//
//  Created by Ali on 18/12/2025.
//

import UIKit

class TimeCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    func configure(time: String, isSelected: Bool) {
        timeLabel.text = time

        if isSelected {
            containerView.backgroundColor = .systemBlue
            timeLabel.textColor = .white
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            containerView.backgroundColor = .clear
            timeLabel.textColor = .label
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
    
}
