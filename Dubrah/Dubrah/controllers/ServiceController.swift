import Firebase

class ServiceController {
    static let shared = ServiceController()
    private let db = Firestore.firestore()
    
    func addService(data:[String: Any]) async throws -> String{
       let docRef = try await db.collection("Service").addDocument(data: data)
        return docRef.documentID
    }
    
    func getAllServices() async throws -> [Service] {
        
        let querySnapshot = try await db.collection("Service").getDocuments()
        
        return querySnapshot.documents.compactMap { Service(document: $0 )}
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
            .whereField("userID", isEqualTo: userId)
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
