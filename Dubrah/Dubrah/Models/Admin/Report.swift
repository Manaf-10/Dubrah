//
//  Report.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 02/01/2026.
//

import Foundation
import FirebaseFirestore

struct Report: Codable, Identifiable {
    let id: String  // Document ID from Firestore
    let reportId: String  // reportId field
    let userId: String  // Reporter's ID
    let orderId: String
    let reportType: String  // "service" or "user"
    let title: String
    let description: String
    let status: String  // "pending", "resolved", "ignored"
    let createdAt: Date
    
    // Fetched separately from Order and User collections
    var reporterName: String?
    var reporterEmail: String?
    var reporterAvatar: String?
    var reportedUserName: String?  // Provider name
    var reportedUserId: String?    // Provider ID
    var reportedUserAvatar: String?
    var serviceName: String?
    var serviceId: String?
    
    init?(id: String, data: [String: Any]) {
        guard
            let reportId = data["reportId"] as? String,
            let userId = data["userId"] as? String,
            let orderId = data["orderId"] as? String,
            let reportType = data["reportType"] as? String,
            let title = data["title"] as? String,
            let description = data["description"] as? String,
            let status = data["status"] as? String,
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()
        else { return nil }
        
        self.id = id
        self.reportId = reportId
        self.userId = userId
        self.orderId = orderId
        self.reportType = reportType
        self.title = title
        self.description = description
        self.status = status
        self.createdAt = createdAt
    }
}
