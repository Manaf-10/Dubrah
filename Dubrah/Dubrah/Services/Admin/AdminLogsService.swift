//
//  AdminLogsService.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 04/01/2026.
//

import FirebaseFirestore
import FirebaseAuth

final class AdminLogsService {
    
    private let db = Firestore.firestore()
    
    // MARK: - Fetch All Logs (Combined from multiple sources)
    
    func fetchAllLogs(completion: @escaping ([Log]) -> Void) {
        let group = DispatchGroup()
        var allLogs: [Log] = []
        
        // 1. Fetch user registrations
        group.enter()
        fetchUserRegistrations { logs in
            allLogs.append(contentsOf: logs)
            group.leave()
        }
        
        // 2. Fetch verification requests
        group.enter()
        fetchVerificationRequests { logs in
            allLogs.append(contentsOf: logs)
            group.leave()
        }
        
        // 3. Fetch report submissions
        group.enter()
        fetchReportSubmissions { logs in
            allLogs.append(contentsOf: logs)
            group.leave()
        }
        
        // 4. Fetch admin action logs
        group.enter()
        fetchAdminActionLogs { logs in
            allLogs.append(contentsOf: logs)
            group.leave()
        }
        
        group.notify(queue: .main) {
            // Sort all logs by timestamp (newest first)
            let sortedLogs = allLogs.sorted { $0.timestamp > $1.timestamp }
            print("✅ Total logs fetched: \(sortedLogs.count)")
            completion(sortedLogs)
        }
    }
    
    // MARK: - Fetch User Registrations
    
    private func fetchUserRegistrations(completion: @escaping ([Log]) -> Void) {
        db.collection("user")
            .order(by: "createdAt", descending: true)
            .limit(to: 20)  // Last 20 registrations
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Error fetching users: \(error)")
                    completion([])
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let logs: [Log] = docs.compactMap { doc in
                    guard
                        let fullName = doc.data()["fullName"] as? String,
                        let createdAt = (doc.data()["createdAt"] as? Timestamp)?.dateValue()
                    else { return nil }
                    
                    return Log(
                        id: "user_\(doc.documentID)",
                        action: .userRegistered,
                        username: fullName,
                        targetUsername: nil,
                        timestamp: createdAt,
                        details: nil
                    )
                }
                
                print("✅ Fetched \(logs.count) user registrations")
                completion(logs)
            }
    }
    
    // MARK: - Fetch Verification Requests
    
    private func fetchVerificationRequests(completion: @escaping ([Log]) -> Void) {
        db.collection("Requests")
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .getDocuments { [weak self] snapshot, error in
                
                if let error = error {
                    print("❌ Error fetching requests: \(error)")
                    completion([])
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                
                var logs: [Log] = []
                let group = DispatchGroup()
                
                for doc in docs {
                    guard
                        let userId = doc.data()["userId"] as? String,
                        let createdAt = (doc.data()["createdAt"] as? Timestamp)?.dateValue()
                    else { continue }
                    
                    group.enter()
                    
                    // Fetch user name
                    self?.db.collection("user").document(userId).getDocument { userSnapshot, _ in
                        let username = userSnapshot?.data()?["fullName"] as? String ?? "Unknown User"
                        
                        let log = Log(
                            id: "request_\(doc.documentID)",
                            action: .verificationRequest,
                            username: username,
                            targetUsername: nil,
                            timestamp: createdAt,
                            details: nil
                        )
                        
                        logs.append(log)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    print("✅ Fetched \(logs.count) verification requests")
                    completion(logs)
                }
            }
    }
    
    // MARK: - Fetch Report Submissions
    
    private func fetchReportSubmissions(completion: @escaping ([Log]) -> Void) {
        db.collection("reports")
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .getDocuments { [weak self] snapshot, error in
                
                if let error = error {
                    print("❌ Error fetching reports: \(error)")
                    completion([])
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                
                var logs: [Log] = []
                let group = DispatchGroup()
                
                for doc in docs {
                    guard
                        let userId = doc.data()["userId"] as? String,
                        let title = doc.data()["title"] as? String,
                        let createdAt = (doc.data()["createdAt"] as? Timestamp)?.dateValue()
                    else { continue }
                    
                    group.enter()
                    
                    // Fetch user name
                    self?.db.collection("user").document(userId).getDocument { userSnapshot, _ in
                        let username = userSnapshot?.data()?["fullName"] as? String ?? "Unknown User"
                        
                        let log = Log(
                            id: "report_\(doc.documentID)",
                            action: .reportSubmitted,
                            username: username,
                            targetUsername: nil,
                            timestamp: createdAt,
                            details: title
                        )
                        
                        logs.append(log)
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    print("✅ Fetched \(logs.count) report submissions")
                    completion(logs)
                }
            }
    }
    
    // MARK: - Fetch Admin Action Logs
    
    private func fetchAdminActionLogs(completion: @escaping ([Log]) -> Void) {
        db.collection("logs")
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("❌ Error fetching admin logs: \(error)")
                    completion([])
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let logs: [Log] = docs.compactMap { doc in
                    guard
                        let actionString = doc.data()["action"] as? String,
                        let action = LogAction(rawValue: actionString),
                        let username = doc.data()["username"] as? String,
                        let timestamp = (doc.data()["timestamp"] as? Timestamp)?.dateValue()
                    else { return nil }
                    
                    let targetUsername = doc.data()["targetUsername"] as? String
                    let details = doc.data()["details"] as? String
                    
                    return Log(
                        id: "log_\(doc.documentID)",
                        action: action,
                        username: username,
                        targetUsername: targetUsername,
                        timestamp: timestamp,
                        details: details
                    )
                }
                
                print("✅ Fetched \(logs.count) admin action logs")
                completion(logs)
            }
    }
    
    // MARK: - Log Admin Action (Only for admin actions)
    
    func logAdminAction(
        action: LogAction,
        targetUsername: String? = nil,
        details: String? = nil
    ) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("⚠️ No admin logged in")
            return
        }
        
        // Fetch admin name
        db.collection("user").document(currentUserId).getDocument { [weak self] snapshot, error in
            let adminName = snapshot?.data()?["fullName"] as? String ?? "Admin"
            
            let logData: [String: Any] = [
                "action": action.rawValue,
                "userId": currentUserId,
                "username": adminName,
                "targetUsername": targetUsername ?? "",
                "details": details ?? "",
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            self?.db.collection("logs").addDocument(data: logData) { error in
                if let error = error {
                    print("❌ Failed to log action: \(error)")
                } else {
                    print("✅ Logged admin action: \(action.rawValue)")
                }
            }
        }
    }
}
