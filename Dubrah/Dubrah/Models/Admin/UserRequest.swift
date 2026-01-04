//
//  UserRequest.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import Foundation

struct UserRequest {
    let userId: String
    let name: String
    let role: String
    let profilePictureUrl: String?
    let documents: [VerificationDocument]
}
