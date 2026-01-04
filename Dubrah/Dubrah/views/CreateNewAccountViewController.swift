import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateNewAccountViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var Continuebtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Continuebtn.layer.cornerRadius = 12
        Continuebtn.clipsToBounds = true
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, isValidEmail(email) else {
            showAlert(message: "Invalid email format")
            return
        }
        
        signUpWithEmail(email: email)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    func signUpWithEmail(email: String) {
        Auth.auth().createUser(withEmail: email, password: "temporaryPassword") { authResult, error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            
            
            guard let user = authResult?.user else {
                self.showAlert(message: "User creation failed. Please try again.")
                return
            }
            
          
            user.sendEmailVerification { error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                
                
                if let userEmail = user.email {
                    let db = Firestore.firestore()
                    let userRef = db.collection("user").document(user.uid)
                    
                    userRef.setData([
                        "email": userEmail,
                        "notifications": [],
                        "orderHistory" : [],
                        "status": ""
                    ], merge: true) { error in
                        if let error = error {
                            self.showAlert(message: "Error saving email to Firestore: \(error.localizedDescription)")
                            return
                        } else {
                            print("Email successfully saved to Firestore!")
                        }
                    }
                } else {
                    self.showAlert(message: "Email not available.")
                }
                
                // Perform segue after email verification is sent
                self.performSegue(withIdentifier: "GoToVerifyEmail", sender: nil)
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
