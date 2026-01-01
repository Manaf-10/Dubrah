import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var SendResetCodebtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SendResetCodebtn.layer.cornerRadius = 12
        SendResetCodebtn.clipsToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendVerificationLinkTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email.")
            return
        }

        // Validate email format
        if !isValidEmail(email) {
            showAlert(message: "Please enter a valid email address.")
            return
        }

        // Send email verification link using temporary password
        sendEmailVerificationLink(email: email)
    }

    // Validate email format
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }

    // Send email verification link
    func sendEmailVerificationLink(email: String) {
        // Temporary password for signing in (this is just for this purpose, in a real app, this would need a secure flow)
        let temporaryPassword = "123456"
        
        // Sign in with temporary password
        Auth.auth().signIn(withEmail: email, password: temporaryPassword) { authResult, error in
            if let error = error {
                self.showAlert(message: "Error signing in: \(error.localizedDescription)")
                return
            }
            
            // Once signed in, send the email verification link
            authResult?.user.sendEmailVerification { error in
                if let error = error {
                    self.showAlert(message: "Error sending verification email: \(error.localizedDescription)")
                    return
                }

                self.performSegue(withIdentifier: "VerifyEmailViewController", sender: nil)
            }
        }
    }

    // Show alert messages
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Email Verification", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
