import UIKit
import FirebaseFirestore
import FirebaseAuth
import Cloudinary

class verifyIdentityViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var ContinueBtn: UIButton!
    @IBOutlet weak var UploadIdFrontandBack: UIButton!
    
    var frontImage: UIImage?   // To hold the front image
    var backImage: UIImage?    // To hold the back image
    var imageSelectionCount = 0  // To keep track of how many images are selected (0, 1, or 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ContinueBtn.isEnabled = false  // Disable continue button initially
        ContinueBtn.layer.cornerRadius = 12.0
        ContinueBtn.clipsToBounds = true
   
    }

    // Action triggered when the user taps the upload button
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        // Show image picker to upload the first image (front)
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        present(imagePickerController, animated: true)
    }
    
    // Action triggered when the user taps the continue button
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        // Proceed to save or upload both front and back images
        if let frontImage = frontImage, let backImage = backImage {
            uploadImages(frontImage: frontImage, backImage: backImage)
            self.performSegue(withIdentifier: "GoToTellUs", sender: nil)
        } else {
            showAlert(message: "Please select both front and back images.")
        }
    }

    func uploadImages(frontImage: UIImage, backImage: UIImage) {
        // Upload the front image first
        MediaManager.shared.uploadImage(frontImage) { result in
            switch result {
            case .success(let frontImageUrl):
                print("Front image uploaded: \(frontImageUrl)")
                
                // After successfully uploading the front image, upload the back image
                MediaManager.shared.uploadImage(backImage) { result in
                    switch result {
                    case .success(let backImageUrl):
                        print("Back image uploaded: \(backImageUrl)")
                        
                        // Both images are uploaded, now save the URLs to Firestore
                        self.saveImageUrlsToFirestore(frontImageUrl: frontImageUrl, backImageUrl: backImageUrl)
                        
                    case .failure(let error):
                        // Handle failure in uploading the back image
                        self.showAlert(message: "Failed to upload back image: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                // Handle failure in uploading the front image
                self.showAlert(message: "Failed to upload front image: \(error.localizedDescription)")
            }
        }
    }

    // Save the image URLs to Firestore
    func saveImageUrlsToFirestore(frontImageUrl: String, backImageUrl: String) {
        let userRef = Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid)
        
        userRef.updateData([
            "frontImageUrl": frontImageUrl,
            "backImageUrl": backImageUrl
        ]) { error in
            if let error = error {
                // Handle Firestore save failure
                self.showAlert(message: "Failed to save image URLs: \(error.localizedDescription)")
            } else {
                // Success - You can now proceed to the next step
                print("Image URLs saved successfully")
                self.showAlert(message: "Identity verification completed successfully.")
                self.performSegue(withIdentifier: "GoToTellUs", sender: nil)  // Navigate to the next screen
            }
        }
    }

    // Function to show alert message
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    // MARK: - UIImagePickerControllerDelegate
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
                ContinueBtn.isEnabled = true // Enable continue button after both images are selected
                imageSelectionCount += 1
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
