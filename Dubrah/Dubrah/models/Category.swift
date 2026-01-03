//
//  Category.swift
//  Dubrah
//
//  Created by Sayed on 23/12/2025.
//


struct Category: Identifiable{
    let id: String
    let title: String
    
    var firestoreData: [String: Any] {
        return [
            "title": title,
            "id": id
        ]
    }
}
