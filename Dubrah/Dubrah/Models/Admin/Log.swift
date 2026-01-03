//
//  Log.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 24/12/2025.
//

// Log.swift
import UIKit

struct Log {
    let icon: UIImage
    let description: String
    let username: String
    let time: Date
}


extension Log {
    
    static var allLogs: [Log] = [
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Ahmed Ali",
            time: Date().addingTimeInterval(-2 * 3600)), // 2h ago
        
        Log(icon: UIImage(named: "Log-Action")!,
            description: "New report created",
            username: "Fatima Mohamed",
            time: Date().addingTimeInterval(-8 * 3600)), // 8h ago
        
        Log(icon: UIImage(named: "Log-Verify")!,
            description: "New verification request",
            username: "Mahmoud Ahmed",
            time: Date().addingTimeInterval(-12 * 3600)), // 12h ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Abdulla Eisa",
            time: Date(timeIntervalSinceNow: -3 * 86400)), // 3 days ago
        
        Log(icon: UIImage(named: "Log-Profile")!,
            description: "New user registered",
            username: "Mohamed Jasim",
            time: Date(timeIntervalSinceNow: -5 * 86400)) // 5 days ago
    ].sorted { $0.time > $1.time }
}
