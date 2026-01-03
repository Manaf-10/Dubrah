//
//  DateCollectionViewCell.swift
//  Dubrah
//
//  Created by Ali on 18/12/2025.
//

import UIKit

class DateCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    func configure(day: String, date: String, isSelected: Bool) {
        dayLabel.text = day
        dateLabel.text = date

        if isSelected {
            containerView.backgroundColor = .systemBlue
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
            dayLabel.textColor = .white
            dateLabel.textColor = .white
        } else {
            containerView.backgroundColor = .clear
            containerView.layer.borderColor = UIColor.systemGray4.cgColor
            dayLabel.textColor = .label
            dateLabel.textColor = .label
        }
    }

}
