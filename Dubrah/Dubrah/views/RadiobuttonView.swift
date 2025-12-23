//
//  RadiobuttonView.swift
//  Dubrah
//
//  Created by Ali on 20/12/2025.
//

import UIKit

class RadiobuttonView: UIView {
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var isSelectedOption: Bool = false {
        didSet { updateUI() }
    }
    override func awakeFromNib() {
        circleView.layer.cornerRadius = circleView.frame.height / 2
        circleView.layer.borderWidth = 2
        circleView.layer.borderColor = UIColor.systemGray3.cgColor
        circleView.backgroundColor = .clear
    }
    func updateUI() {
        if isSelectedOption {
            circleView.layer.borderColor = UIColor.systemBlue.cgColor
            circleView.backgroundColor = UIColor.systemBlue
        }
        else {
            circleView.layer.borderColor = UIColor.systemGray3.cgColor
            circleView.backgroundColor = .clear	
        }
    }
}
