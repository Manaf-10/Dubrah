//
//  AdminRequestsService.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import FirebaseFirestore

final class AdminRequestsService {

    private let db = Firestore.firestore()

    func fetchRequests(completion: @escaping ([UserRequest]) -> Void) {
        
        // ✅ Step 1: Get all unverified providers from user collection
        db.collection("user")
            .whereField("role", isEqualTo: "provider")  // Must be provider
            .whereField("verified", isEqualTo: false)   // Not verified yet
            .getDocuments { [weak self] snapshot, error in
                
                if let error = error {
                    print("❌ Error fetching requests: \(error)")
                    completion([])
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    print("⚠️ No pending verification requests found")
                    completion([])
                    return
                }
                
                print("✅ Found \(docs.count) pending provider requests")
                
                var results: [UserRequest] = []
                let group = DispatchGroup()
                
                // ✅ Step 2: For each user, get their provider details
                for doc in docs {
                    let userId = doc.documentID
                    let userData = doc.data()
                    
                    guard
                        let fullName = userData["fullName"] as? String,
                        let userName = userData["userName"] as? String
                    else { continue }
                    
                    group.enter()
                    
                    // Fetch their verification documents from ProviderDetails
                    self?.fetchProviderDetails(userId: userId) { providerDetails in
                        defer { group.leave() }
                        
                        let user = AppUser(
                            id: userId,
                            fullName: fullName,
                            userName: userName,
                            role: "Provider",
                            profilePicture: userData["profilePicture"] as? String,
                            verified: false
                        )
                        
                        let documents: [VerificationDocument]
                        
                        if let details = providerDetails {
                            // User has uploaded verification documents
                            documents = [
                                VerificationDocument(urlString: details.frontImageUrl),
                                VerificationDocument(urlString: details.backImageUrl)
                            ]
                        } else {
                            // User applied but hasn't uploaded documents yet
                            print("⚠️ User \(fullName) has no documents uploaded")
                            documents = []
                        }
                        
                        let request = UserRequest(
                            userId: userId,
                            name: user.fullName,
                            role: user.role,
                            profilePictureUrl: user.profilePicture,
                            documents: documents
                        )
                        
                        results.append(request)
                    }
                }
                
                group.notify(queue: .main) {
                    print("✅ Returning \(results.count) verification requests")
                    completion(results)
                }
            }
    }
    
    // ✅ Fetch provider verification documents using your existing model
    private func fetchProviderDetails(
        userId: String,
        completion: @escaping (ProviderDetails?) -> Void
    ) {
        db.collection("ProviderDetails")
            .whereField("userId", isEqualTo: userId)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Error fetching provider details: \(error)")
                    completion(nil)
                    return
                }
                
                guard
                    let doc = snapshot?.documents.first,
                    let details = ProviderDetails(data: doc.data())
                else {
                    print("⚠️ No ProviderDetails found for userId: \(userId)")
                    completion(nil)
                    return
                }
                
                print("✅ Found provider details for userId: \(userId)")
                completion(details)
            }
    }
}
