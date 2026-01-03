//
//  PortfolioItem.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

struct PortfolioItem {
    let image: UIImage
    let title: String
    let date: String
}

extension PortfolioItem {
    static let mock: [PortfolioItem] = [
        PortfolioItem(image: UIImage(named: "Log-Profile")!, title: "Fintech Web App", date: "March 15, 2023"),
        PortfolioItem(image: UIImage(named: "Log-Profile")!, title: "E-commerce Web App", date: "Oct 21, 2023")
    ]
}
