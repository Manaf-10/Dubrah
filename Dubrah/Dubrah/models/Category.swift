//
//  Category.swift
//  Dubrah
//
//  Created by Sayed on 23/12/2025.
//


struct Category: Identifiable{
    var id: String?
    let title: String
    
    var firestoreData: [String: Any] {
        return [
            "title": title,
            "id": id ?? "placeholder"
        ]
    }
}

var categories: [Category] = []
