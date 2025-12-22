//
//  User.swift
//  Dubrah
//
//  Created by Manaf on 22/12/2025.

import FirebaseAuth
import FirebaseFirestore

struct User: Identifiable {
    var id: String?
    let email: String
    let fullName: String
    let createdAt: Date
    
    // Add this computed property
    var firestoreData: [String: Any] {
        return [
            "email": email,
            "fullName": fullName,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
    
    // Optional: Helper to create from document
    static func from(document: DocumentSnapshot) -> User? {
        guard let data = document.data() else { return nil }
        
        return User(
            id: document.documentID,
            email: data["email"] as? String ?? "",
            fullName: data["fullName"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
}
