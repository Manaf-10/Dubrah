import Firebase

class ServiceController {
    static let shared = ServiceController()
    private let db = Firestore.firestore()
    
    func addService(data:[String: Any]) async throws -> String{
       let docRef = try await db.collection("Service").addDocument(data: data)
        return docRef.documentID
    }
    
    func getAllServices() async throws -> [Service] {

        let snapshot = try await db.collection("Service").getDocuments()
        var services: [Service] = []

        for doc in snapshot.documents {
            let data = doc.data()

            let id = doc.documentID
            let title = (data["title"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let description = (data["description"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let providerID = data["providerID"] as? String ?? ""

            let price: Double = {
                if let p = data["price"] as? Double { return p }
                if let p = data["price"] as? Int { return Double(p) }
                if let p = data["price"] as? String, let v = Double(p) { return v }
                return 0
            }()

            // image can be missing -> set empty string (cell will show placeholder)
            let image = data["image"] as? String ?? ""

            // These may be used elsewhere (safe defaults)
            let category = data["category"] as? String ?? ""
            let duration = data["duration"] as? Int ?? 0
            let paymentMethods =
                (data["paymentMethods"] as? [String]) ??
                (data["paymentMethod"] as? [String]) ??
                []

            let createdAt: Date = {
                if let ts = data["createdAt"] as? Timestamp { return ts.dateValue() }
                return Date()
            }()

            let reviewData = data["reviews"] as? [[String: Any]] ?? []
            let reviews = reviewData.compactMap { Review(dictionary: $0) }

            // Build object
            let service = Service(
                id: id,
                category: category,
                title: title,
                description: description,
                price: price,
                duration: duration,
                image: image,
                providerID:  await getUserField(from: providerID, field: "userName") as? String ?? "",
                paymentMethods: paymentMethods,
                createdAt: createdAt,
                reviews: reviews
            )

            services.append(service)
        }

        return services
    }


    func getServiceDetails(id: String) async throws -> Service? {
        let docRef = db.collection("Service").document(id)
            let document = try await docRef.getDocument()
            
            guard document.exists else {
                return nil
            }
            
            let querySnapshot = try await db.collection("Service")
                .whereField(FieldPath.documentID(), isEqualTo: id)
                .getDocuments()
            
            guard let serviceDocument = querySnapshot.documents.first else {
                return nil
            }
            
            return Service(document: serviceDocument)
    }
   
    func editService(id : String ,updatedData: [String: Any])async throws{
        
        let docRef = db.collection( "Service" ).document( id )
        
        try await docRef.updateData(updatedData)
    }
    
    func deleteService(id: String) async throws {
        try await db.collection("Service").document(id).delete()
    }
    
    func addReview(serviceId: String, review: [String: Any]) async throws {
        let docRef = db.collection("Service").document(serviceId)
        
        try await docRef.updateData([
            "reviews": FieldValue.arrayUnion([review])
        ])
    }
    func addProviderReview(userId: String, review: [String: Any]) async throws {
        // Query to find the provider document by userID field
        let querySnapshot = try await db.collection("ProviderDetails")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        guard let document = querySnapshot.documents.first else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Provider not found"])
        }
        
        // Update the found document with the new review
        try await document.reference.updateData([
            "reviews": FieldValue.arrayUnion([review])
        ])
    }
}
