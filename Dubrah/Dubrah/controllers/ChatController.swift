//
//  ChatController.swift
//  Dubrah
//
//  Created by Sayed on 24/12/2025.
//

import FirebaseFirestore
import FirebaseAuth

class ChatController {
    static let shared = ChatController()
    private let db = Firestore.firestore()
    
    func generateChatID(user1ID: String, user2ID: String) -> String {
        return [user1ID, user2ID].sorted().joined(separator: "-")
    }

    func getUserChats(userID: String) async throws -> [Chat] {
        // Fetching chats for the user
        let snapshot = try await db.collection("Chat")
            .whereField("participants", arrayContains: userID)
            .getDocuments()
        
        print("Fetched \(snapshot.documents.count) chats for userID: \(userID)") // Log number of chats

        var fetchedChats: [Chat] = []
        
        // Iterate through each chat document
        for doc in snapshot.documents {
            let data = doc.data()
            
            let participants = data["participants"] as? [String] ?? []
            print("Participants for chat \(doc.documentID): \(participants)")
            
            if participants.count != 2 {
                print("Error: Invalid number of participants in chat \(doc.documentID). Expected 2, got \(participants.count).")
                continue
            }

            let otherID = participants.first(where: { $0 != userID }) ?? ""
            print("Filtered otherID: \(otherID)")
            
            if otherID.isEmpty {
                print("Error: Empty otherID for chat \(doc.documentID). Skipping.")
                continue
            }

            print("Fetching user details for otherID: \(otherID)")
            
            let name = await getUserField(from: otherID, field: "userName") as? String ?? "User"
            let image = await getUserField(from: otherID, field: "profilePicture") as? String ?? ""
            let verified: Bool = await getUserField(from: otherID, field: "verified") as! Bool
            
            // Fetch messages for the chat
            let messagesData = data["messages"] as? [[String: Any]] ?? []
            let messages = messagesData.map { dict in
                Message(
                    content: dict["content"] as? String ?? "",
                    isIncoming: (dict["senderID"] as? String ?? "") != userID,
                    senderID: dict["senderID"] as? String ?? "",
                    timestamp: (dict["CreatedAt"] as? Timestamp)?.dateValue() ?? Date()
                )
            }
            
            // Log the details fetched for the other user and the messages
            print("Fetched details for \(otherID): Name - \(name), Verified - \(verified), Image - \(image)")
            
            // Log the messages fetched for the chat
            print("Fetched \(messages.count) messages for chat \(doc.documentID)")

            // Append the fetched chat to the list
            fetchedChats.append(Chat(id: doc.documentID, messages: messages, userImage: image, userName: name, receiverID: otherID, verified: verified))
        }

        // Return the list of fetched chats
        return fetchedChats
    }



    // Real-time listener for a specific chat room
    func observeMessages(chatID: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        let currentUID = Auth.auth().currentUser?.uid ?? ""
        return db.collection("Chat").document(chatID).addSnapshotListener { snapshot, _ in
            guard let data = snapshot?.data(), let msgData = data["messages"] as? [[String: Any]] else { return }
            let msgs = msgData.map { dict in
                Message(
                    content: dict["content"] as? String ?? "",
                    isIncoming: (dict["senderID"] as? String ?? "") != currentUID,
                    senderID: dict["senderID"] as? String ?? "",
                    timestamp: (dict["CreatedAt"] as? Timestamp)?.dateValue() ?? Date()
                )
            }
            completion(msgs)
        }
    }

    func sendMessage(chatID: String, senderID: String, content: String) async throws {
        let messageData: [String: Any] = [
            "content": content,
            "senderID": senderID,
            "CreatedAt": Timestamp(date: Date())
        ]
        try await db.collection("Chat").document(chatID).updateData([
            "messages": FieldValue.arrayUnion([messageData]),
            "lastMessage": content,
            "lastMessageTimestamp": Timestamp(date: Date())
        ])
    }
    
    func getOrCreateChat(user1ID: String, user2ID: String) async throws -> String {
        let chatID = generateChatID(user1ID: user1ID, user2ID: user2ID)
        let ref = db.collection("Chat").document(chatID)

        let doc = try await ref.getDocument()
        if doc.exists { return chatID }

        let chatData: [String: Any] = [
            "participants": [user1ID, user2ID],
            "messages": [],
            "createdAt": Timestamp(date: Date()),
            "lastMessage": "",
            "lastMessageTimestamp": Timestamp(date: Date())
        ]

        try await ref.setData(chatData)
        return chatID
    }

}
