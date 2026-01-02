import UIKit
import FirebaseFirestore
import FirebaseAuth
import Cloudinary

class verifyIdentityViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var ContinueBtn: UIButton!
    @IBOutlet weak var UploadIdFrontandBack: UIButton!
    
    var frontImage: UIImage?
    var backImage: UIImage?
    var imageSelectionCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ContinueBtn.isEnabled = false
        ContinueBtn.layer.cornerRadius = 12.0
        ContinueBtn.clipsToBounds = true
    }

    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true)
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if let frontImage = frontImage, let backImage = backImage {
            uploadImages(frontImage: frontImage, backImage: backImage)
            self.performSegue(withIdentifier: "GoToTellUs", sender: nil)
        } else {
            showAlert(message: "Please select both front and back images.")
        }
    }

    func uploadImages(frontImage: UIImage, backImage: UIImage) {
        // Upload Front Image
        MediaManager.shared.uploadImage(frontImage) { result in
            switch result {
            case .success(let frontImageUrl):
                print("Front image uploaded: \(frontImageUrl)")
                
                // Upload Back Image after Front Image is uploaded
                MediaManager.shared.uploadImage(backImage) { result in
                    switch result {
                    case .success(let backImageUrl):
                        print("Back image uploaded: \(backImageUrl)")
                        
                        // Save the image URLs to Firestore under 'ProviderDetails'
                        self.saveImageUrlsToFirestore(frontImageUrl: frontImageUrl, backImageUrl: backImageUrl)
                    case .failure(let error):
                        self.showAlert(message: "Failed to upload back image: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                self.showAlert(message: "Failed to upload front image: \(error.localizedDescription)")
            }
        }
    }

    func saveImageUrlsToFirestore(frontImageUrl: String, backImageUrl: String) {
        // Reference to 'ProviderDetails' collection
        let providerDetailsRef = Firestore.firestore().collection("ProviderDetails")
        
        // Generate a new document with auto-generated ID
        let newProviderDetailsDocRef = providerDetailsRef.addDocument(data: [
            "userId": Auth.auth().currentUser!.uid,  // Add the user ID as a field
            "frontImageUrl": frontImageUrl,
            "backImageUrl": backImageUrl,
            "timestamp": FieldValue.serverTimestamp() // Optional: You can add a timestamp field
        ]) { error in
            if let error = error {
                self.showAlert(message: "Failed to save image URLs: \(error.localizedDescription)")
            } else {
                print("Image URLs saved successfully in ProviderDetails with auto-generated ID")
                self.showAlert(message: "Identity verification completed successfully.")
                self.performSegue(withIdentifier: "GoToTellUs", sender: nil)
            }
        }
    }


    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if imageSelectionCount == 0 {
            // First image (front)
            if let selectedImage = info[.originalImage] as? UIImage {
                frontImage = selectedImage
                print("Front Image Selected")
                imageSelectionCount += 1
            }
        } else if imageSelectionCount == 1 {
            // Second image (back)
            if let selectedImage = info[.originalImage] as? UIImage {
                backImage = selectedImage
                print("Back Image Selected")
                ContinueBtn.isEnabled = true
                imageSelectionCount += 1
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
