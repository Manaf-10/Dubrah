//
//  Certificate.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

struct Certificate {
    let image: UIImage
}

extension Certificate {
    static let mock: [Certificate] = [
        Certificate(image: UIImage(named: "Log-Profile")!),
        Certificate(image: UIImage(named: "Log-Profile")!)
    ]
}
