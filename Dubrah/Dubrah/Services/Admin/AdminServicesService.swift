//
//  AdminServicesService.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import FirebaseFirestore

final class AdminServicesService {
    
    private let db = Firestore.firestore()
    
    func fetchServices(completion: @escaping ([Service]) -> Void) {
        
        db.collection("Service")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                
                if let error = error {
                    print("❌ Error fetching services: \(error)")
                    completion([])
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    print("⚠️ No services found")
                    completion([])
                    return
                }
                
                print("✅ Found \(docs.count) services")
                
                var services: [Service] = []
                let group = DispatchGroup()
                
                for doc in docs {
                    guard var service = Service(id: doc.documentID, data: doc.data()) else {
                        continue
                    }
                    
                    group.enter()
                    
                    // Fetch provider details
                    self?.fetchProviderInfo(userId: service.providerID) { providerName, providerAvatar in
                        service.providerName = providerName
                        service.providerAvatar = providerAvatar
                        services.append(service)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    print("✅ Returning \(services.count) services with provider info")
                    completion(services)
                }
            }
    }
    
    private func fetchProviderInfo(
        userId: String,
        completion: @escaping (String?, String?) -> Void
    ) {
        db.collection("user")
            .document(userId)
            .getDocument { snapshot, error in
                
                guard
                    let data = snapshot?.data(),
                    let fullName = data["fullName"] as? String
                else {
                    completion("Unknown Provider", nil)
                    return
                }
                
                let avatar = data["profilePicture"] as? String
                completion(fullName, avatar)
            }
    }
    
    // Delete service
    func deleteService(serviceId: String, completion: @escaping (Bool) -> Void) {
        db.collection("Service")
            .document(serviceId)
            .delete { error in
                if let error = error {
                    print("❌ Error deleting service: \(error)")
                    completion(false)
                } else {
                    print("✅ Service deleted successfully")
                    completion(true)
                }
            }
    }
    
    // Update service
    func updateService(serviceId: String, title: String, description: String, completion: @escaping (Bool) -> Void) {
        db.collection("Service")
            .document(serviceId)
            .updateData([
                "title": title,
                "description": description
            ]) { error in
                if let error = error {
                    print("❌ Error updating service: \(error)")
                    completion(false)
                } else {
                    print("✅ Service updated successfully")
                    completion(true)
                }
            }
    }
}
