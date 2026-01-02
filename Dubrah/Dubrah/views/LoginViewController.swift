import UIKit
import FirebaseAuth

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
        
        
        Task {
            do {
                
                try await AuthManager.shared.signIn(email: email, password: password)
                
                
                self.performSegue(withIdentifier: "goToHomePage", sender: nil)
                
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

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHomePage" {
            
        }
    }
}
