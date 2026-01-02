//
//  MediaManager.swift
//  Dubrah
//
//  Created by Sayed on 22/12/2025.
//

import UIKit
import Cloudinary
import FirebaseFirestore
import FirebaseAuth

class MediaManager {
    static let shared = MediaManager()
    
    private init() {}

    func uploadProfilePicture(image: UIImage, documentID: String? = nil) {
        // 1. Get AppDelegate instance to use the Cloudinary object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // 2. Convert Image to Data
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }

        print("DEBUG: Starting Cloudinary Upload...")

        // 3. Upload to Cloudinary
        appDelegate.cloudinary.createUploader().upload(data: imageData, uploadPreset: "gbn4c96o")
            .response { (result, error) in
                if let error = error {
                    print("❌ Cloudinary Error: \(error.localizedDescription)")
                    return
                }

                if let url = result?.secureUrl {
                    print("✅ Cloudinary Success! URL: \(url)")
                    if let serviceID = documentID {
                        // If documentID (the "random number" ID) exists, save to Service
                        print("DEBUG: Saving to Service collection with ID: \(serviceID)")
                        self.saveImageURLtoServceInFirestore(url: url, serviceID: serviceID)
                    } else {
                        // If no ID is provided, perform the normal profile save
                        print("DEBUG: Saving to User profile")
                        self.saveImageUrlToFirestore(url: url)
                    }
                }
            }
    }

    private func saveImageUrlToFirestore(url: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("user").document(uid).updateData([
            "profilePicture": url
        ]) { error in
            if let error = error {
                print("❌ Firestore Update Error: \(error.localizedDescription)")
            } else {
                print("✅ Firestore Profile Picture Updated!")
            }
        }
    }
    
    private func saveImageURLtoServceInFirestore (url: String, serviceID: String) {
        Firestore.firestore().collection("Service").document(serviceID).updateData([
            "image": url
        ]) {error in
            if let error = error {
                print("❌ Firestore Update Error: \(error.localizedDescription)")
            } else {
                print("✅ Firestore Servcice Picture Updated!")
            }
        }
    }
    
}
