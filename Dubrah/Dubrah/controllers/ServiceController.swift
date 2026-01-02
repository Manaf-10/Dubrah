//
//  CategoriesController.swift
//  Dubrah
//
//  Created by Mohamed Ali on 23/12/2025.
//

import Firebase

class ServiceController {
    static let shared = ServiceController()
    private let db = Firestore.firestore()  // Add this line
    
    func addService(data:[String: Any]) async throws -> String{
       let docRef = try await db.collection("Service").addDocument(data: data)
        return docRef.documentID
    }
    
    func getAllServices() async throws -> [Service] {
        
        let querySnapshot = try await db.collection("Service").getDocuments()
        
        return querySnapshot.documents.compactMap { Service(document: $0 )}
    }
    
    func editService(id : String ,updatedData: [String: Any])async throws{
        
        let docRef = db.collection( "Service" ).document( id )
        
        try await docRef.updateData(updatedData)
    }
    
    func deleteService(id: String) async throws {
        try await db.collection("Service").document(id).delete()
    }
    
}
