//
//  AuthManager.swift
//  Dubrah
//
//  Created by Manaf on 22/12/2025.
//

import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    private init() {
        // Check if user is already logged in when app starts
        self.userSession = Auth.auth().currentUser
        
        // Fetch user data if logged in
        if userSession != nil {
            Task {
                do{
                    try await fetchUser()
                }
                catch {
                    print("DEBU G: Error fetching user in init: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, fullName: String, profilePicture: String) async throws -> User {
        // 1. Create auth account
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        self.userSession = authResult.user
        
        // 2. Create user object with all required fields
        let user = User(
            id: authResult.user.uid,
            email: email,
            fullName: fullName,
            userName: "",
            role: "customer",
            isVerified: false,
            createdAt: Date(),
            profilePicture: profilePicture,
            notifications: nil
        )
        
        // 3. Save to Firestore
        try await Firestore.firestore()
            .collection("user")
            .document(authResult.user.uid)
            .setData(user.firestoreData)
        
        // 4. Update local state
        await MainActor.run {
            self.currentUser = user
        }
        
        return user
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        self.userSession = authResult.user
        try await fetchUser()
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error)")
        }
    }
    
    // MARK: - Fetch Current User
    @MainActor
    func fetchUser() async throws {
        guard let uid = userSession?.uid else {
            print("No user session")
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore()
                .collection("user")
                .document(uid)
                .getDocument()
            
            guard snapshot.exists, let data = snapshot.data() else {
                print("User document doesn't exist")
                return
            }
            
            // Create User from Firestore data
            self.currentUser = User(
                        id: snapshot.documentID,
                        email: data["email"] as? String ?? "",
                        fullName: data["fullName"] as? String ?? "",
                        userName: data["userName"] as? String ?? "",
                        role: data["role"] as? String ?? "customer",
                        isVerified: data["verified"] as? Bool ?? false,
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                        profilePicture: (data["profilePicture"] as? String ?? ""),
                        notifications: nil
                    )
            print("✅ User fetched: \(self.currentUser?.fullName ?? "Unknown")")
        } catch {
            print("❌ Error fetching user: \(error)")
            throw error
        }
    }
    
    // MARK: - Check Authentication State
    func checkAuthState() {
        if let user = Auth.auth().currentUser {
            self.userSession = user
            Task {
                do {
                    try await fetchUser()
                } catch {
                    print("DEBUG: Failed to fetch user: \(error.localizedDescription)")
                }
            }
        } else {
            self.userSession = nil
            self.currentUser = nil
        }
    }
}
