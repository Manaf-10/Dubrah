//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class SecuritySettingsViewController: UIViewController {

    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var dobLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changePasswordBtn.layer.cornerRadius = 12
        changePasswordBtn.clipsToBounds = true
        
       
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        
        
        fetchUserData(userID: userID)
    }
    
    func fetchUserData(userID: String) {
        
        let db = Firestore.firestore()
        
        
        let userRef = db.collection("user").document(userID)
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error)")
            } else {
                if let document = document, document.exists {
                    let data = document.data()
                    
                    
                    if let email = Auth.auth().currentUser?.email {
                        self.emailLabel.text = email
                    } else {
                        self.emailLabel.isHidden = true
                    }
                    
                    
                    if let dateOfBirth = data?["dateOfBirth"] as? String, !dateOfBirth.isEmpty {
                        self.dobLabel.text = dateOfBirth
                    } else {
                        self.dobLabel.isHidden = true
                    }
                } else {
                    print("User document does not exist")
                }
            }
        }
    }
}
