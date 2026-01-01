import UIKit
import Cloudinary
import FirebaseFirestore
import FirebaseAuth

class MediaManager {
    static let shared = MediaManager()
    
    private init() {}
    
    // Replace with your Cloudinary credentials
    let cloudName = "dcothxbxk"
    let uploadPreset = "ios_products_preset"
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Convert image to JPEG format
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "CloudinaryUploader", code: 100, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        // Create the URL for Cloudinary
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the boundary and content type for multipart form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add upload preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"product.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set the body of the request
        request.httpBody = body
        
        // Perform the upload with a URLSession data task
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completion(.failure(error))  // Pass the error back using the Result type
                return
            }
            
            // Parse the JSON response
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let secureUrl = json["secure_url"] as? String else {
                let unknownError = NSError(domain: "CloudinaryUploader", code: 101, userInfo: [NSLocalizedDescriptionKey: "Failed to parse Cloudinary response"])
                completion(.failure(unknownError))  // Return failure with custom error if parsing fails
                return
            }
            
            // Return the secure URL of the uploaded image using Result.success
            completion(.success(secureUrl))
        }.resume()
    }
}
