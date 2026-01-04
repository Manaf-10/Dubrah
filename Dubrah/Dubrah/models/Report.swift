import Foundation
import FirebaseFirestore

struct Report: Codable, Identifiable {
    let id: String  // Document ID from Firestore
    let reportId: String
    let userId: String
    let orderId: String
    let reportType: String  // "service" or "provider"
    let title: String
    let description: String
    let status: String  // "pending", "resolved", "ignored"
    let createdAt: Date
    
    // ✅ Your enriched data (fetched separately)
    var reporterName: String?
    var reporterEmail: String?
    var reporterAvatar: String?
    var reportedUserName: String?
    var reportedUserId: String?
    var reportedUserAvatar: String?
    var serviceName: String?
    var serviceId: String?
    
    // ✅ Your init (for reading from Firestore)
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
    
    // ✅ Their init (for creating new reports)
    init(
        id: String = UUID().uuidString,
        reportId: String = UUID().uuidString,
        userId: String,
        orderId: String,
        reportType: String,
        title: String,
        description: String,
        status: String = "pending",
        createdAt: Date = Date()
    ) {
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
    
    // ✅ Their dictionary property (for saving to Firestore)
    var dictionary: [String: Any] {
        return [
            "reportId": reportId,
            "userId": userId,
            "orderId": orderId,
            "reportType": reportType,
            "title": title,
            "description": description,
            "status": status,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}
