//
//  AdminProviderDetails.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import Foundation

struct ProviderDetails {
    let userId: String
    let frontImageUrl: String
    let backImageUrl: String

    init?(data: [String: Any]) {
        guard
            let userId = data["userId"] as? String,
            let front = data["frontImageUrl"] as? String,
            let back = data["backImageUrl"] as? String
        else { return nil }

        self.userId = userId
        self.frontImageUrl = front
        self.backImageUrl = back
    }
}
