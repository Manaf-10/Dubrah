//
//  AdminUsersService.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import FirebaseFirestore

final class AdminUsersService {

    private let db = Firestore.firestore()

    func fetchUsers(completion: @escaping ([AppUser]) -> Void) {

        db.collection("user")
            .getDocuments { snapshot, error in

                guard let docs = snapshot?.documents else {
                    completion([])
                    return
                }

                let users = docs.compactMap { doc -> AppUser? in
                    AppUser(id: doc.documentID, data: doc.data())
                }

                completion(users)
            }
    }
}
