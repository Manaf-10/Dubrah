//
//  Request.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 24/12/2025.
//

import UIKit

struct Request {
    let username: String
    let role: String
    let photo: UIImage
}

extension Request {
    static var allRequests: [Request] = [
        Request(username: "Ahmed Ali", role: "Student", photo: UIImage(named: "Log-Profile")!),
        Request(username: "Fatima Mohamed", role: "Teacher", photo: UIImage(named: "Log-Profile")!),
        Request(username: "Mahmoud Ahmed", role: "Admin", photo: UIImage(named: "Log-Profile")!),
        Request(username: "Abdulla Eisa", role: "Moderator", photo: UIImage(named: "Log-Profile")!),
        Request(username: "Mohamed Jasim", role: "Student", photo: UIImage(named: "Log-Profile")!)
    ]
}
