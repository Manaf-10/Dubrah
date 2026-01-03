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

    init?(id: String, data: [String: Any]) {
        self.id = id
        self.category = data["category"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.price = data["price"] as? Double ?? 0.0
        self.duration = data["duration"] as? Int ?? 0
        self.image = data["image"] as? String ?? ""
        self.providerID = data["providerID"] as? String ?? ""

        self.paymentMethods =
            (data["paymentMethods"] as? [String]) ??
            (data["paymentMethod"] as? [String]) ??
            []

        let reviewData = data["reviews"] as? [[String: Any]] ?? []
        self.reviews = reviewData.compactMap { Review(dictionary: $0) }

        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
    }

    init?(document: QueryDocumentSnapshot) {
        self.init(id: document.documentID, data: document.data())
    }

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(id: document.documentID, data: data)
    }

    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        let total = reviews.reduce(0) { $0 + $1.rate }
        return Double(total) / Double(reviews.count)
    }
}
