//
//  User.swift
//  Dubrah
//
//  Created by Manaf on 22/12/2025.

import FirebaseAuth
import FirebaseFirestore

struct User: Identifiable {
        let id: String?
        let email: String
        let fullName: String
        let userName: String
        let role: String
        let isVerified: Bool
        let createdAt: Date
        let profilePicture: String    
    var firestoreData: [String: Any] {
        return [
            "email": email,
            "fullName": fullName,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}
