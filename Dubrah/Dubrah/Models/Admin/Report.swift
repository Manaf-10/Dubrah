//
//  Report.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 02/01/2026.
//

import UIKit

struct Report {
    let username: String
    let email: String
    let type: String   // Users / Services etc
    let title: String
    let description: String
    let reportedUser: String
    let avatar: UIImage
    let reportedAvatar: UIImage
}

extension Report {
    static let allReports: [Report] = [
        Report(
            username: "Ahmed Ali",
            email: "ahmed.ali@gmail.com",
            type: "Users",
            title: "This provider is a fraud",
            description: "I was asked to pay outside the app, and the service was never completed.",
            reportedUser: "Mohammed Ahmed",
            avatar: UIImage(named: "Log-Profile")!,
            reportedAvatar: UIImage(named: "Log-Profile")!
        ),
        Report(
            username: "Mohamed Jasim",
            email: "mohamed.jasim@gmail.com",
            type: "Users",
            title: "Inappropriate behavior",
            description: "The provider used rude language during the conversation and refused to provide details.",
            reportedUser: "Salman Ali",
            avatar: UIImage(named: "Log-Profile")!,
            reportedAvatar: UIImage(named: "Log-Profile")!
        )
    ]
}
