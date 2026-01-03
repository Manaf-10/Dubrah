//
//  VerificationDocument.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 02/01/2026.
//

import UIKit

struct VerificationDocument {
    let imageName: String
}

extension VerificationDocument {
    static let mockData: [VerificationDocument] = [
        VerificationDocument(imageName: "Verify-doc1"),
        VerificationDocument(imageName: "Verify-doc2"),
        VerificationDocument(imageName: "Verify-doc1"),
        VerificationDocument(imageName: "Verify-doc2")
    ]
}

