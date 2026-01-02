//
//  NotificationController.swift
//  Dubrah
//
//  Created by Sayed on 23/12/2025.
//

import FirebaseFirestore
import FirebaseAuth
class NotificationController{
    
    static let shared = NotificationController()
    
    enum NotificationType{
        case message
        case review
        case report
        
    }
    
    private init() {}
    
    // MARK: - Firebase Fetching
    func getUserNotifications(uid: String) async throws -> [Notification] {
        let snapshot = try await db.collection("user").document(uid).getDocument()
        
        guard let data = snapshot.data(),
              let notificationMaps = data["notifications"] as? [[String: Any]] else {
            return []
        }
        
        var fetchedNotifications: [Notification] = []
        var pfpCache: [String: String] = [:]
        
        for map in notificationMaps {
            let content = map["content"] as? String ?? ""
            let timestamp = map["createdAt"] as? Timestamp ?? Timestamp()
            guard let senderRef = map["senderID"] as? DocumentReference else { continue }
            let pfp = await getUserField(from: senderRef.documentID, field: "profileImage") as? String
            var notification = Notification(
                content: content,
                createdAt: timestamp.dateValue(),
                senderID: senderRef,
                senderImage: pfp
            )
            
            // Check cache before fetching from network
            if let cachedImage = pfpCache[senderRef.path] {
                notification.senderImage = cachedImage
            } else {
                do {
                    let senderDoc = try await senderRef.getDocument()
                    let pfp = senderDoc.data()?["profilePicture"] as? String
                    notification.senderImage = pfp
                    pfpCache[senderRef.path] = pfp // Store in cache
                } catch {
                    print("Error fetching sender pfp: \(error)")
                }
            }
            fetchedNotifications.append(notification)
        }
        
        return fetchedNotifications.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    func deleteNotificationFromFirestore(notificationId: String?) {
        guard let uid = Auth.auth().currentUser?.uid,
              let docId = notificationId else { return }
        
        Firestore.firestore()
            .collection("user")
            .document(uid)
            .collection("notifications")
            .document(docId)
            .delete { error in
                if let error = error {
                    print("DEBUG: Failed to delete notification from Firestore: \(error.localizedDescription)")
                } else {
                    print("DEBUG: Notification successfully deleted from Firestore")
                }
            }
    }
    
    func newNotification(receiverId: String, senderId: String, type: NotificationType) async {
        let userRef = db.collection("user").document(receiverId)
        let senderRef = db.collection("user").document(senderId)
        
        // 1. Fetch the sender's username
        let username = await getUserField(from: senderId, field: "userName")
        
        // 2. Build content with proper spacing
        let content: String
        switch type {
        case .message: content = "\(username ?? "Unknown") has left you a message!"
        case .review:  content = "\(username ?? "Unknown") left you a review!"
        case .report:  content = "Your account has a new report."
        }
        
        // 3. Prepare the notification map
        let newNotif: [String: Any] = [
            "content": content,
            "senderID": senderRef,
            "createdAt": Timestamp(date: Date())
        ]
        
        do {
            try await userRef.updateData([
                "notifications": FieldValue.arrayUnion([newNotif])
            ])
            print("DEBUG: Successfully appended to array!")
        } catch {
            print("DEBUG: Failed to update Firestore: \(error.localizedDescription)")
        }
    }
}
