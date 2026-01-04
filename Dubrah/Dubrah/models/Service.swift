import Foundation
import FirebaseFirestore

struct Service:  Identifiable {
    let id: String
    var category: String
    var title: String
    var description: String
    var price: Double
    var duration: Int
    var image: String
    var providerID: String
    var paymentMethod: [String]  // Support both names
    var createdAt: Date
    
    var paymentMethods: [String] {
            get { return paymentMethod }
            set { paymentMethod = newValue }
        }
    
    // ✅ Support BOTH review formats
    var reviewIDs: [String]?  // Your approach (IDs)
    var reviews: [Review]?    // Their approach (objects)
    
    // ✅ Your additions
    var providerName: String?
    var providerAvatar: String?
    
    // ✅ Primary init (flexible, like theirs)
    init?(id: String, data: [String: Any]) {
        self.id = id
        self.category = data["category"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.price = data["price"] as? Double ?? 0.0
        self.duration = data["duration"] as? Int ?? 0
        self.image = data["image"] as? String ?? ""
        self.providerID = data["providerID"] as? String ?? ""
        
        // ✅ Handle both paymentMethod names
        self.paymentMethod =
            (data["paymentMethod"] as? [String]) ??
            (data["paymentMethods"] as? [String]) ??
            []
        
        // ✅ Handle reviews as objects (their way)
        if let reviewData = data["reviews"] as? [[String: Any]] {
            self.reviews = reviewData.compactMap { Review(dictionary: $0) }
            self.reviewIDs = nil
        }
        // ✅ Handle reviews as IDs (your way)
        else if let ids = data["reviews"] as? [String] {
            self.reviewIDs = ids
            self.reviews = nil
        }
        else {
            self.reviews = nil
            self.reviewIDs = nil
        }
        
        // ✅ Handle createdAt
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
        
        // ✅ Your additions
        self.providerName = nil
        self.providerAvatar = nil
    }
    
    // ✅ Keep their convenience init
    init(
        id: String,
        category: String,
        title: String,
        description: String,
        price: Double,
        duration: Int,
        image: String,
        providerID: String,
        paymentMethods: [String],
        createdAt: Date,
        reviews: [Review]? = nil,
        reviewIDs: [String]? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.description = description
        self.price = price
        self.duration = duration
        self.image = image
        self.providerID = providerID
        self.paymentMethod = paymentMethods
        self.createdAt = createdAt
        self.reviews = reviews
        self.reviewIDs = reviewIDs
        self.providerName = nil
        self.providerAvatar = nil
    }
    
    // ✅ Keep their document inits
    init?(document: QueryDocumentSnapshot) {
        self.init(id: document.documentID, data: document.data())
    }

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        self.init(id: document.documentID, data: data)
    }

    // ✅ Keep their computed property
    var averageRating: Double {
        guard let reviews = reviews, !reviews.isEmpty else { return 0 }
        let total = reviews.reduce(0) { $0 + $1.rate }
        return Double(total) / Double(reviews.count)
    }
}
