import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class EditBioViewController: UIViewController {

   
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var userID: String?
    var currentBio: String?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }
        self.userID = userID
        fetchUserBio(userID: userID)
        
        saveButton.layer.cornerRadius = 12
        saveButton.clipsToBounds = true
        
      
        bioTextView.layer.borderWidth = 1
        bioTextView.layer.borderColor = UIColor.gray.cgColor
        bioTextView.layer.cornerRadius = 8
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
  
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
                
                
                self.bioTextView.text = self.currentBio
            } else {
                print("User document does not exist")
            }
        }
    }
    
    
    @IBAction func saveChangesTapped(_ sender: UIButton) {
       
        guard let newBio = bioTextView.text else {
            return
        }
        
        
        if newBio != currentBio {
            
            updateUserBio(newBio: newBio)
        } else {
           
            showBioUnchangedMessage()
        }
    }
    
 
    @IBAction func cancelTapped(_ sender: UIButton) {
        
        bioTextView.text = currentBio
    }
    
   
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
                
                self.currentBio = newBio
                
                self.showBioUpdatedMessage()
            }
        }
    }
    
   
    func showBioUnchangedMessage() {
        let alert = UIAlertController(title: "No Changes", message: "Your bio is the same as before.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showBioUpdatedMessage() {
        let alert = UIAlertController(title: "Success", message: "Your bio has been updated.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

