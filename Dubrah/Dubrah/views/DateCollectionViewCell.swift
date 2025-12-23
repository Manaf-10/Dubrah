//
//  DateCollectionViewCell.swift
//  Dubrah
//
//  Created by Ali on 18/12/2025.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    func configure(day: String, date: String, isSelected: Bool, isAvailable: Bool) {
        
        dayLabel.text = day
        dateLabel.text = date
        
        if !isAvailable {
            containerView.backgroundColor = UIColor.systemGray5
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
            dayLabel.textColor = .systemGray
            dateLabel.textColor = .systemGray
            return
        }
        
        dayLabel.textColor = .label
        dateLabel.textColor = .label
        
        if isSelected {
            containerView.backgroundColor = UIColor.systemBlue
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
            dayLabel.textColor = .white
            dateLabel.textColor = .white
        } else {
            containerView.backgroundColor = .clear
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
}
