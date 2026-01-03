//
//  Service.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

struct Service {
    let image: UIImage
    let title: String
    let provider: String
    let avatar: UIImage
    let description: String
}

extension Service {
    static let mock: [Service] = [
        Service(
            image: UIImage(named: "Log-Profile")!,
            title: "Home Deep Cleaning",
            provider: "Mohamed Jasim",
            avatar:  UIImage(named: "Log-Profile")!,
            description: "Comprehensive deep cleaning service for apartments and villas."
        ),
        Service(
            image: UIImage(named: "Log-Profile")!,
            title: "Car Washing",
            provider: "Ali Yaser",
            avatar:  UIImage(named: "Log-Profile")!,
            description: "Professional mobile car wash service offering interior and exterior."
        )
    ]
}
