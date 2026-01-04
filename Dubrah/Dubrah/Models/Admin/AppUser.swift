//
//  AppUser.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import Foundation

struct AppUser: Codable {
    let id: String
    let fullName: String
    let userName: String
    let role: String
    let profilePicture: String?
    let verified: Bool
    
    var displayRole: String {
        verified ? "Verified Provider" : "Pending Provider"
    }

    // ✅ Init from Firestore document
    init?(id: String, data: [String: Any]) {
        guard
            let fullName = data["fullName"] as? String,
            let userName = data["userName"] as? String
        else { return nil }

        self.id = id
        self.fullName = fullName
        self.userName = userName
        
        let verified = data["verified"] as? Bool ?? false
        self.verified = verified
        self.role = data["role"] as? String ?? (verified ? "Provider" : "User")
        
        self.profilePicture = data["profilePicture"] as? String
    }
    
    // ✅ NEW: Direct init (for service layer)
    init(id: String,
         fullName: String,
         userName: String,
         role: String,
         profilePicture: String?,
         verified: Bool) {
        self.id = id
        self.fullName = fullName
        self.userName = userName
        self.role = role
        self.profilePicture = profilePicture
        self.verified = verified
    }
}
