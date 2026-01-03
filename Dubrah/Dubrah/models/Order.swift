import Foundation
import FirebaseFirestore

struct Order {
    let id: String
    var orderDate: Date
    var paymentMethod: String
    var providerFeedback: String
    var providerID: String
    var providerRating: Int
    var serviceFeedback: String
    var serviceID: String
    var serviceImageUrl: String
    var serviceName: String
    var serviceRating: Int
    var status: String
    var userID: String
    var subtotal: String
    

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        self.id = document.documentID

        // orderDate
        if let timestamp = data["orderDate"] as? Timestamp {
            self.orderDate = timestamp.dateValue()
        } else {
            self.orderDate = Date()
        }
        
        self.serviceFeedback = data["serviceFeedback"] as? String ?? ""
        self.providerFeedback = data["providerFeedback"] as? String ?? ""
        self.providerID = data["providerID"] as? String ?? ""
        self.serviceID = data["serviceId"] as? String ?? ""
        self.providerRating = data["providerRating"] as? Int ?? 0
        self.serviceImageUrl = data["serviceImageUrl"] as? String ?? ""
        self.serviceName = data["serviceName"] as? String ?? ""
        self.serviceRating = data["serviceRating"] as? Int ?? 0
        self.status = data["status"] as? String ?? "pending"
        self.userID = data["userID"] as? String ?? ""
        self.subtotal = data["subtotal"] as? String ?? ""
        self.paymentMethod = data["paymentMethod"] as? String ?? ""
    }
}
