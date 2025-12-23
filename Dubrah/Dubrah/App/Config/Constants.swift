//
//  Constants.swift
//  Dubrah
//
//  Created by Abdulla Mohd Shams on 02/12/2025.
//
import FirebaseFirestore

let db = Firestore.firestore()
let reportSystemID = "JYqgIGPb9n3uP1kYCYhn"

func getUsername(from uid: String) async -> String {
    do {
        let document = try await db.collection("user").document(uid).getDocument()
        if let data = document.data() {
            return data["userName"] as? String ?? "Anonymous"
        }
    } catch {
        print("Error: \(error)")
    }
    return "Unknown"
}

func getUserField(from uid: String, field: String) async -> Any?{
    do{
        let document = try await db.collection("user").document(uid).getDocument()
        if let data = document.data() {
            return data[field] as? String ?? "Unknown"
        }
    }catch {
            print("DEBUG: Error fetching field \(field): \(error)")
        }
    return nil
    }

