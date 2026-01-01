//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class SecuritySettingsViewController: UIViewController {

    // UI Elements
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var dobLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the user is logged in
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        
        // Fetch the user's data from Firestore
        fetchUserData(userID: userID)
    }
    
    func fetchUserData(userID: String) {
        // Reference to Firestore database
        let db = Firestore.firestore()
        
        // Fetch User Data (from 'user' collection)
        let userRef = db.collection("user").document(userID)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    
                    // Set email from Firebase Authentication
                    if let email = Auth.auth().currentUser?.email {
                        self.emailLabel.text = email
                    } else {
                        self.emailLabel.isHidden = true // Hide if no email data
                    }
                    
                    // Set date of birth from Firestore
                    if let dateOfBirth = data?["dateOfBirth"] as? String, !dateOfBirth.isEmpty {
                        self.dobLabel.text = dateOfBirth
                    } else {
                        self.dobLabel.isHidden = true // Hide if no date of birth data
                    }
                } else {
                    print("User document does not exist")
                }
            }
        }
    }
}
