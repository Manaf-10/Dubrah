//
//  VerificationDocument.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 02/01/2026.
//

import Foundation

struct VerificationDocument {

    /// Firebase image URL
    let urlString: String?

    /// Local mock image name
    let imageName: String?

    init(urlString: String) {
        self.urlString = urlString
        self.imageName = nil
    }

    init(imageName: String) {
        self.imageName = imageName
        self.urlString = nil
    }
}

extension VerificationDocument {
    static let mockData: [VerificationDocument] = [
        VerificationDocument(imageName: "Verify-doc1"),
        VerificationDocument(imageName: "Verify-doc2"),
        VerificationDocument(imageName: "Verify-doc1"),
        VerificationDocument(imageName: "Verify-doc2")
    ]
}
