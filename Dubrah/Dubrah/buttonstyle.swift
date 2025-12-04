//
//  buttonstyle.swift
//  Dubrah
//
//  Created by BP-36-201-17 on 04/12/2025.
//

import UIKit

class buttonstyle: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 12
        clipsToBounds = true
        
    }
}
