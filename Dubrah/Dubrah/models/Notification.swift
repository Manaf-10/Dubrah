//
//  Notification.swift
//  Dubrah
//
//  Created by Sayed on 22/12/2025.
//

import Foundation
import FirebaseFirestore

struct Notification: Codable {
    let content: String
    let createdAt: Date
    let senderID: DocumentReference
    var senderImage: String?
}
