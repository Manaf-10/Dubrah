import Firebase

class OrderController {
    static let shared = OrderController()
    private let db = Firestore.firestore()
    
    private let collectionName = "orders"
    
    func addOrder(data: [String: Any]) async throws -> String {
        let docRef = try await db.collection(collectionName).addDocument(data: data)
        return docRef.documentID
    }
    
    func getAllOrders() async throws -> [Order] {
        let querySnapshot = try await db.collection(collectionName).getDocuments()
        return querySnapshot.documents.compactMap { Order(document: $0) }
    }
    
    func getOrdersByProvider(providerID: String) async throws -> [Order] {
        let querySnapshot = try await db.collection(collectionName)
            .whereField("providerID", isEqualTo: providerID)
            .getDocuments()
        return querySnapshot.documents.compactMap { Order(document: $0) }
    }
    
    func getOrdersByUser(userID: String) async throws -> [Order] {
        let querySnapshot = try await db.collection(collectionName)
            .whereField("userID", isEqualTo: userID)
            .getDocuments()
        return querySnapshot.documents.compactMap { Order(document: $0) }
    }
    
    func getOrdersByStatus(providerID: String, status: String) async throws -> [Order] {
        let querySnapshot = try await db.collection(collectionName)
            .whereField("providerID", isEqualTo: providerID)
            .whereField("status", isEqualTo: status)
            .getDocuments()
        return querySnapshot.documents.compactMap { Order(document: $0) }
    }
    
    func updateOrderStatus(id: String, status: String) async throws {
        let docRef = db.collection(collectionName).document(id)
        try await docRef.updateData(["status": status])
    }
    
    func updateOrder(id: String, updatedData: [String: Any]) async throws {
        let docRef = db.collection(collectionName).document(id)
        try await docRef.updateData(updatedData)
    }
    
    func deleteOrder(id: String) async throws {
        try await db.collection(collectionName).document(id).delete()
    }
    

    // Update the method to return both
    func getUserData(userID: String) async throws -> UserData {
        let document = try await db.collection("user").document(userID).getDocument()
        let data = document.data() ?? [:]
        
        let fullName = data["fullName"] as? String ?? "Unknown User"
        let profilePicture = data["profilePicture"] as? String ?? ""
                
        return UserData(fullName: fullName, profilePicture: profilePicture)
    }
}
