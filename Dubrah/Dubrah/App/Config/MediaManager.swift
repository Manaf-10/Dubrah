import UIKit
import Cloudinary
import FirebaseFirestore
import FirebaseAuth

final class MediaManager {

    static let shared = MediaManager()
    private init() {}

    private let db = Firestore.firestore()

    func uploadProfilePicture(
        image: UIImage,
        documentID: String? = nil,
        completion: ((Result<String, Error>) -> Void)? = nil
    ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion?(.failure(NSError(domain: "MediaManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "AppDelegate not found"])))
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion?(.failure(NSError(domain: "MediaManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data"])))
            return
        }

        print("DEBUG: Starting Cloudinary Upload...")

        appDelegate.cloudinary.createUploader()
            .upload(data: imageData, uploadPreset: "gbn4c96o")
            .response { [weak self] result, error in
                guard let self else { return }

                if let error = error {
                    print("❌ Cloudinary Error: \(error.localizedDescription)")
                    completion?(.failure(error))
                    return
                }

                guard let url = result?.secureUrl, !url.isEmpty else {
                    completion?(.failure(NSError(domain: "MediaManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cloudinary did not return a secure URL"])))
                    return
                }

                print("✅ Cloudinary Success! URL: \(url)")

                if let serviceID = documentID, !serviceID.isEmpty {
                    print("DEBUG: Saving to Service collection with ID: \(serviceID)")
                    self.saveServiceImageURL(url: url, serviceID: serviceID) { saveResult in
                        completion?(saveResult.map { _ in url })
                    }
                } else {
                    print("DEBUG: Saving to User profile")
                    self.saveUserProfileImageURL(url: url) { saveResult in
                        completion?(saveResult.map { _ in url })
                    }
                }
            }
    }

    // MARK: - Firestore Saves

    private func saveUserProfileImageURL(
        url: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "MediaManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }

        // ✅ CHANGE THESE if your app uses "Users" or a different field name
        db.collection("User").document(uid).setData(
            ["profileImage": url],
            merge: true
        ) { error in
            if let error = error {
                print("❌ Firestore User Update Error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Firestore User Profile Picture Updated!")
                completion(.success(()))
            }
        }
    }

    private func saveServiceImageURL(
        url: String,
        serviceID: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("Service").document(serviceID).updateData([
            "image": url
        ]) { error in
            if let error = error {
                print("❌ Firestore Service Update Error: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Firestore Service Picture Updated!")
                completion(.success(()))
            }
        }
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {

        let cloudName = "dcothxbxk"
        let uploadPreset = "ios_products_preset"

        // Convert image to JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(
                NSError(
                    domain: "CloudinaryUploader",
                    code: 100,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"]
                )
            ))
            return
        }

        // Cloudinary upload URL
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Multipart form-data boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Upload preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)

        // Image file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        // Perform upload
        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let secureUrl = json["secure_url"] as? String
            else {
                completion(.failure(
                    NSError(
                        domain: "CloudinaryUploader",
                        code: 101,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to parse Cloudinary response"]
                    )
                ))
                return
            }

            completion(.success(secureUrl))

        }.resume()
    }

    
}
