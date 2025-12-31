//
//  Constants.swift
//  Dubrah
//
//  Created by Abdulla Mohd Shams on 02/12/2025.
//
import FirebaseFirestore
import Cloudinary

let db = Firestore.firestore()

let reportSystemID = "JYqgIGPb9n3uP1kYCYhn"

// Add this inside your ChatController class
func getUserField(from userID: String, field: String) async -> Any? {
    do {
        // Assumes your users are stored in a collection named "Users"
        let doc = try await db.collection("user").document(userID).getDocument()
        return doc.data()?[field]
    } catch {
        print("❌ Error fetching user field: \(error)")
        return nil
    }
}

func upload(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Initialize Cloudinary configuration
        let config = CLDConfiguration(cloudName: "your-cloud-name", apiKey: "your-api-key", apiSecret: "your-api-secret")
        let cloudinary = CLDCloudinary(configuration: config)
        
        // Convert image to data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "CloudinaryUploader", code: 100, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        // Upload the image to Cloudinary
    cloudinary.createUploader().upload(data: imageData, uploadPreset: "your-upload-preset", completionHandler:  { result, error in
        if let error = error {
            completion(.failure(error))
        } else if let result = result, let secureUrl = result.secureUrl {
            // Directly use secureUrl since it's already a String
            completion(.success(secureUrl))
        } else {
            completion(.failure(NSError(domain: "CloudinaryUploader", code: 101, userInfo: [NSLocalizedDescriptionKey: "Unknown error during upload"])))
        }
    })
    }


