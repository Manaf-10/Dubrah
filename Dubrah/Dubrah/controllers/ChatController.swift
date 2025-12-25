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
   
    func newChat(user1ID: String, user2ID: String) async throws -> String {
        let chatID = generateChatID(user1ID: user1ID, user2ID: user2ID)
        let chatData: [String: Any] = [
            "chatID": chatID,
            "CreatedAt": Timestamp(date: Date()),
            "user1ID": user1ID,
            "user2ID": user2ID,
            "participants": [user1ID, user2ID],
            "lastMessage": "",
            "lastMessageTimestamp": Timestamp(date: Date()),
            "messages": []
        ]
        
        try await db.collection("Chat").document(chatID).setData(chatData)
        return chatID
    }
    
    func generateChatID(user1ID: String, user2ID: String) -> String {
        let sortedIDs = [user1ID, user2ID].sorted()
        return sortedIDs.joined(separator: "-")
    }
    
    func getUserChats(userID: String) async throws -> [String] {
        let snapshot = try await db.collection("Chat")
            .whereField("participants", arrayContains: userID)
            .getDocuments()
        
        return snapshot.documents.map { $0.documentID }
    }
    
    func sendMessage(chatID: String, senderID: String, content: String) async throws {
        let messageData: [String: Any] = [
            "content": content,
            "senderID": senderID,
            "CreatedAt": Timestamp(date: Date())
        ]
        
        let chatRef = db.collection("Chat").document(chatID)
        let chatDocument = try await chatRef.getDocument()
        
        if let chatData = chatDocument.data() {

            var messages = chatData["messages"] as? [[String: Any]] ?? []
            
            messages.append(messageData)
            
            try await chatRef.updateData([
                "messages": messages,
                "lastMessage": content,
                "lastMessageTimestamp": Timestamp(date: Date())
            ])
        }
    }

    func chatExists(user1ID: String, user2ID: String) async throws -> (exists: Bool, chatID: String?) {
        let chatID = generateChatID(user1ID: user1ID, user2ID: user2ID)
        
        let document = try await db.collection("Chat").document(chatID).getDocument()
        
        if document.exists {
            return (true, chatID)
        }
        return (false, nil)
    }
    
    func getOrCreateChat(user1ID: String, user2ID: String) async throws -> String {
        let (exists, existingChatID) = try await chatExists(user1ID: user1ID, user2ID: user2ID)
        
        if exists, let chatID = existingChatID {
            return chatID
        } else {
            return try await newChat(user1ID: user1ID, user2ID: user2ID)
        }
    }
    
    func getChatWithUser(currentUserID: String, otherUserID: String) async throws -> String {
        return try await getOrCreateChat(user1ID: currentUserID, user2ID: otherUserID)
    }
    
    func deleteChat(chatID: String) async throws {
        try await db.collection("Chat").document(chatID).delete()
    }
    
}
