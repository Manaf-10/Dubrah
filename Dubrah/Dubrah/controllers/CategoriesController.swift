//
//  CategoriesController.swift
//  Dubrah
//
//  Created by Sayed on 23/12/2025.
//

import Firebase

class CategoriesController{
    static let shared = CategoriesController()
    private let db = Firestore.firestore()  // Add this line
    
    func addCategory(name: String) async throws{
        try await db.collection("Category").addDocument(data: ["name": name])
    }
    
    func getAllCategories() async throws -> [Category] {
        
        let querySnapshot = try await db.collection("Category").getDocuments()
        
        let fetchedCategories = querySnapshot.documents.compactMap { document -> Category? in
            let data = document.data()
            let name = data["name"] as? String ?? ""
            let id = document.documentID
            return Category(id: id, title: name)
        }
        
        return fetchedCategories
    }
    
    func editCategory(id : String ,newName: String)async throws{
        
        let docRef = db.collection( "Category" ).document( id )
        
        try await docRef.updateData([
                "name": newName
            ])
    }
    
    func deleteCategory(id : String)async throws{
        
        let docRef = db.collection( "Category" ).document( id )
        
        try await docRef.delete()
        
    }
}
