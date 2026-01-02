//
//  Booking.swift
//  Dubrah
//
//  Created by mohammed ali on 23/12/2025.
//

import Foundation
import FirebaseFirestore

struct Service {
    let id: String
    var category: String
    var title: String
    var description: String
    var price: Double
    var duration: Int
    var image: String
    var providerID: String
    var paymentMethods: [String]
    var createdAt: Date
    var reviews: [Review]

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        self.id = document.documentID
        self.category = data["category"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.price = data["price"] as? Double ?? 0.0
        self.duration = data["duration"] as? Int ?? 0
        self.image = data["image"] as? String ?? ""
        self.providerID = data["providerID"] as? String ?? ""
        self.paymentMethods = data["paymentMethod"] as? [String] ?? []
        let reviewData = data["reviews"] as? [[String: Any]] ?? []
        self.reviews = reviewData.compactMap { Review(dictionary: $0)}
        
        // Handle Firestore Timestamp conversion
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
    }
}
