//
//  Service.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import Foundation
import FirebaseFirestore

struct Service: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    let price: Double
    let category: String
    let image: String  // URL string
    let providerID: String
    let paymentMethod: [String]
    let duration: Int
    let reviews: [String]?  // Array of review IDs
    let createdAt: Date
    
    // Fetched separately (not in Firestore document)
    var providerName: String?
    var providerAvatar: String?
    
    init?(id: String, data: [String: Any]) {
        guard
            let title = data["title"] as? String,
            let description = data["description"] as? String,
            let price = data["price"] as? Double,
            let category = data["category"] as? String,
            let image = data["image"] as? String,
            let providerID = data["providerID"] as? String,
            let paymentMethod = data["paymentMethod"] as? [String],
            let duration = data["duration"] as? Int,
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
        else { return nil }
        
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.category = category
        self.image = image
        self.providerID = providerID
        self.paymentMethod = paymentMethod
        self.duration = duration
        self.reviews = data["reviews"] as? [String]
        self.createdAt = createdAt
        
        // These will be fetched separately
        self.providerName = nil
        self.providerAvatar = nil
    }
}
