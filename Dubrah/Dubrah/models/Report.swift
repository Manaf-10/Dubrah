import Foundation
import FirebaseFirestore

struct Report {
    let reportId: String
    let userId: String
    let orderId: String
    let reportType: String // "service" or "provider"
    let title: String
    let description: String
    let status: String // "pending"
    let createdAt: Date
    
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
