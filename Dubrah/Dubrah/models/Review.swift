import Foundation
import FirebaseFirestore

struct Review {
    var content: String
    var createdAt: Date
    var rate: Int
    var senderID: String

    
        init?(dictionary: [String: Any]) {
            self.content = dictionary["content"] as? String ?? ""
            self.rate = dictionary["rate"] as? Int ?? 0
            self.senderID = dictionary["senderID"] as? String ?? ""
            if let timestamp = dictionary["createdAt"] as? Timestamp {
                self.createdAt = timestamp.dateValue()
            } else {
                self.createdAt = Date()
            }
        }
}
