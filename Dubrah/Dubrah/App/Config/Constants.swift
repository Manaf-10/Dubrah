//
//  Constants.swift
//  Dubrah
//
//  Created by Abdulla Mohd Shams on 02/12/2025.
//
import FirebaseFirestore

let db = Firestore.firestore()

let reportSystemID = "JYqgIGPb9n3uP1kYCYhn"

// Add this inside your ChatController class
func getUserField(from userID: String, field: String) async -> Any? {
    do {
        // Assumes your users are stored in a collection named "Users"
        let doc = try await db.collection("user").document(userID).getDocument()
        return doc.data()?[field]
    } catch {
        print("❌ Error fetching user field: \(error)")
        return nil
    }
}

