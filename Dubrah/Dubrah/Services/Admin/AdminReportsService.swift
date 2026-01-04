//
//  AdminReportsService.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 04/01/2026.
//

import FirebaseFirestore

final class AdminReportsService {
    
    private let db = Firestore.firestore()
    
    // Fetch pending reports
    func fetchPendingReports(completion: @escaping ([Report]) -> Void) {
        fetchReports(status: "pending", completion: completion)
    }
    
    // Fetch report history (resolved or ignored)
    func fetchReportHistory(completion: @escaping ([Report]) -> Void) {
        db.collection("Report")
            .whereField("status", in: ["resolved", "ignored"])
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                self?.processReportsSnapshot(snapshot: snapshot, error: error, completion: completion)
            }
    }
    
    private func fetchReports(status: String, completion: @escaping ([Report]) -> Void) {
        db.collection("Report")
            .whereField("status", isEqualTo: status)
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                self?.processReportsSnapshot(snapshot: snapshot, error: error, completion: completion)
            }
    }
    
    private func processReportsSnapshot(snapshot: QuerySnapshot?, error: Error?, completion: @escaping ([Report]) -> Void) {
        if let error = error {
            print("❌ Error fetching reports: \(error)")
            completion([])
            return
        }
        
        guard let docs = snapshot?.documents else {
            print("⚠️ No reports found")
            completion([])
            return
        }
        
        print("✅ Found \(docs.count) reports")
        
        var reports: [Report] = []
        let group = DispatchGroup()
        
        for doc in docs {
            guard let report = Report(id: doc.documentID, data: doc.data()) else {
                continue
            }
            
            group.enter()
            fetchReportDetails(report: report) { updatedReport in
                if let updatedReport = updatedReport {
                    reports.append(updatedReport)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("✅ Returning \(reports.count) reports with full details")
            completion(reports)
        }
    }
    
    private func fetchReportDetails(report: Report, completion: @escaping (Report?) -> Void) {
        var updatedReport = report
        let group = DispatchGroup()
        
        // Fetch Order details
        group.enter()
        db.collection("orders").document(report.orderId).getDocument { snapshot, error in
            defer { group.leave() }
            
            guard let data = snapshot?.data() else {
                print("⚠️ Order not found: \(report.orderId)")
                return
            }
            
            updatedReport.reportedUserId = data["providerID"] as? String
            updatedReport.serviceName = data["serviceName"] as? String
            updatedReport.serviceId = data["serviceId"] as? String
        }
        
        // Wait for order, then fetch users
        group.notify(queue: .main) { [weak self] in
            let userGroup = DispatchGroup()
            
            // Fetch reporter info
            userGroup.enter()
            self?.fetchUserInfo(userId: report.userId) { name, email, avatar in
                updatedReport.reporterName = name
                updatedReport.reporterEmail = email
                updatedReport.reporterAvatar = avatar
                userGroup.leave()
            }
            
            // Fetch reported user (provider) info
            if let providerId = updatedReport.reportedUserId {
                userGroup.enter()
                self?.fetchUserInfo(userId: providerId) { name, _, avatar in
                    updatedReport.reportedUserName = name
                    updatedReport.reportedUserAvatar = avatar
                    userGroup.leave()
                }
            }
            
            userGroup.notify(queue: .main) {
                completion(updatedReport)
            }
        }
    }
    
    private func fetchUserInfo(
        userId: String,
        completion: @escaping (String?, String?, String?) -> Void
    ) {
        db.collection("user").document(userId).getDocument { snapshot, error in
            guard let data = snapshot?.data() else {
                completion("Unknown User", nil, nil)
                return
            }
            
            let name = data["fullName"] as? String
            let email = data["email"] as? String
            let avatar = data["profilePicture"] as? String
            
            completion(name, email, avatar)
        }
    }
    
    // Update report status
    func updateReportStatus(reportId: String, status: String, completion: @escaping (Bool) -> Void) {
        db.collection("Report")
            .document(reportId)
            .updateData(["status": status]) { error in
                if let error = error {
                    print("❌ Error updating report: \(error)")
                    completion(false)
                } else {
                    print("✅ Report status updated to: \(status)")
                    completion(true)
                }
            }
    }
}
