import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextFeild: UITextField!
    @IBOutlet weak var SigninBtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextFeild.delegate = self
        SigninBtn.layer.cornerRadius = 12.0
        SigninBtn.clipsToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        guard let email = emailTextFeild.text, !email.isEmpty else {
            showAlert(message: "Please enter your email.")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please enter your password.")
            return
        }
        
        print("Attempting to sign in with email: \(email)")
        
        Task {
            do {
                // Sign in using Firebase Authentication
                try await AuthManager.shared.signIn(email: email, password: password)
                
                // Fetch the current user
                if let user = Auth.auth().currentUser {
                    print("User authenticated: \(user.email ?? "No email")")
                    
                  
                    checkUserRole(userId: user.uid)
                } else {
                    print("Authentication failed or no user found.")
                    showAlert(message: "Authentication failed. Please check your credentials.")
                }
                
            } catch let error as NSError {
                
                switch error.code {
                case AuthErrorCode.invalidEmail.rawValue:
                    self.showAlert(message: "The email address is invalid.")
                case AuthErrorCode.wrongPassword.rawValue:
                    self.showAlert(message: "The password is incorrect.")
                case AuthErrorCode.userNotFound.rawValue:
                    self.showAlert(message: "No account found with this email.")
                default:
                    self.showAlert(message: "Sign In failed. Please try again.")
                }
            }
        }
    }

    func checkUserRole(userId: String) {
        let db = Firestore.firestore()
        db.collection("user").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user role: \(error.localizedDescription)")
                self?.showAlert(message: "Error fetching user role. Please try again later.")
                return
            }
            
            guard let document = document, document.exists else {
                print("No user document found in Firestore for UID: \(userId)")
                self?.showAlert(message: "No account found with this email.")
                return
            }
            
            if let role = document.data()?["role"] as? String {
                if role == "admin" {
                    self?.performSegue(withIdentifier: "goToAdminDashboard", sender: nil)
                } else {
                    self?.performSegue(withIdentifier: "goToHomePage", sender: nil)
                }
            } else {
                self?.showAlert(message: "User role not found or is invalid.")
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
