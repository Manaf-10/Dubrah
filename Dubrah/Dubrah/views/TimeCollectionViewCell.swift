//
//  TimeCollectionViewCell.swift
//  Dubrah
//
//  Created by Ali on 18/12/2025.
//

import UIKit

class TimeCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    func configure(time: String, isAvailable: Bool, isSelected: Bool){
        timeLabel.text = time
        if !isAvailable {
                    containerView.backgroundColor = UIColor.systemGray5
                    timeLabel.textColor = UIColor.systemGray
                    containerView.layer.borderColor = UIColor.clear.cgColor
                }
                else if isSelected {
                    containerView.backgroundColor = UIColor.systemBlue
                    timeLabel.textColor = .white
                    containerView.layer.borderColor = UIColor.systemBlue.cgColor
                }
                else {
                    containerView.backgroundColor = .white
                    timeLabel.textColor = .black
                    containerView.layer.borderColor = UIColor.systemGray4.cgColor
                }
    }
    
    
    
}
