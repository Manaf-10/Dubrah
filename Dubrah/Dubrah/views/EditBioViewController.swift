import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class EditBioViewController: UIViewController {

    // UI Elements
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var userID: String?
    var currentBio: String?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the user is logged in and fetch their bio
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        self.userID = userID
        fetchUserBio(userID: userID)
        
        // Optionally, configure the UITextView (e.g., placeholder, appearance)
        bioTextView.layer.borderWidth = 1
        bioTextView.layer.borderColor = UIColor.gray.cgColor
        bioTextView.layer.cornerRadius = 8
    }
    
    // Fetch Bio from Firestore (from 'users' collection)
    func fetchUserBio(userID: String) {
        let userRef = db.collection("user").document(userID)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                self.currentBio = data?["bio"] as? String ?? "No Bio"
                
                // Display the current bio in the text view
                self.bioTextView.text = self.currentBio
            } else {
                print("User document does not exist")
            }
        }
    }
    
    // Save Changes Button
    @IBAction func saveChangesTapped(_ sender: UIButton) {
        // Get the new bio entered by the user
        guard let newBio = bioTextView.text else {
            return
        }
        
        // Check if the bio has changed
        if newBio != currentBio {
            // Update the bio in Firestore
            updateUserBio(newBio: newBio)
        } else {
            // Show a message saying the bio is the same
            showBioUnchangedMessage()
        }
    }
    
    // Cancel Button
    @IBAction func cancelTapped(_ sender: UIButton) {
        // Revert the bio to the original one from Firestore
        bioTextView.text = currentBio
    }
    
    // Update Bio in Firestore
    func updateUserBio(newBio: String) {
        guard let userID = userID else { return }
        
        let userRef = db.collection("user").document(userID)
        
        userRef.updateData([
            "bio": newBio
        ]) { error in
            if let error = error {
                print("Error updating bio: \(error.localizedDescription)")
            } else {
                print("Bio successfully updated")
                // Update the currentBio variable to the new bio
                self.currentBio = newBio
                // Optionally, show a success message or navigate back
                self.showBioUpdatedMessage()
            }
        }
    }
    
    // Show message if bio is unchanged
    func showBioUnchangedMessage() {
        let alert = UIAlertController(title: "No Changes", message: "Your bio is the same as before.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Show message if bio is updated successfully
    func showBioUpdatedMessage() {
        let alert = UIAlertController(title: "Success", message: "Your bio has been updated.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

