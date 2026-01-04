//
//  Log.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 24/12/2025.
//

import UIKit
import FirebaseFirestore

struct Log: Identifiable {
    let id: String
    let action: LogAction
    let username: String
    let targetUsername: String?
    let timestamp: Date
    let details: String?
    
    // Computed property for icon
    var icon: UIImage {
        switch action {
        case .userRegistered:
            return UIImage(named: "Log-Profile") ?? UIImage()
        case .verificationRequest:
            return UIImage(named: "Log-Verify") ?? UIImage()
        default:
            return UIImage(named: "Log-Action") ?? UIImage()
        }
    }
    
    // Computed property for description
    var description: String {
        switch action {
        case .userRegistered:
            return "New user registered"
        case .verificationRequest:
            return "New verification request"
        case .reportSubmitted:
            return "New report submitted"
        case .adminApprovedProvider:
            return "Provider \(targetUsername ?? "user") approved by \(username)"
        case .adminRejectedProvider:
            return "Provider \(targetUsername ?? "user") rejected by \(username)"
        case .adminBannedUser:
            return "User \(targetUsername ?? "user") banned by \(username)"
        case .adminSuspendedUser:
            return "User \(targetUsername ?? "user") suspended by \(username)"
        case .adminUnverifiedUser:
            return "User \(targetUsername ?? "user") unverified by \(username)"
        case .adminDeletedService:
            return "Service deleted by \(username)"
        case .adminModifiedService:
            return "Service modified by \(username)"
        case .adminResolvedReport:
            return "Report resolved by \(username)"
        case .adminIgnoredReport:
            return "Report ignored by \(username)"
        }
    }
}

// MARK: - Log Actions

enum LogAction: String, CaseIterable {
    // Auto-generated from Firebase collections
    case userRegistered = "user_registered"
    case verificationRequest = "verification_request"
    case reportSubmitted = "report_submitted"
    
    // Manually logged admin actions
    case adminApprovedProvider = "admin_approved_provider"
    case adminRejectedProvider = "admin_rejected_provider"
    case adminBannedUser = "admin_banned_user"
    case adminSuspendedUser = "admin_suspended_user"
    case adminUnverifiedUser = "admin_unverified_user"
    case adminDeletedService = "admin_deleted_service"
    case adminModifiedService = "admin_modified_service"
    case adminResolvedReport = "admin_resolved_report"
    case adminIgnoredReport = "admin_ignored_report"
}
