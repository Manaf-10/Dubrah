import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendResetCodebtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendResetCodebtn.layer.cornerRadius = 12
        sendResetCodebtn.clipsToBounds = true
    }
    
    @IBAction func rememberPasswordBtnTapped(_ sender: Any) {
       
          
            if let navigationController = self.navigationController {
                
                if navigationController.viewControllers.count > 2 {
                  
                    let targetViewController = navigationController.viewControllers[navigationController.viewControllers.count - 2]
                    navigationController.popToViewController(targetViewController, animated: true)
                }
            }
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendResetCodeTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter your email.")
            return
        }
        
        if !isValidEmail(email) {
            showAlert(message: "Please enter a valid email address.")
            return
        }
        
        sendPasswordResetLink(email: email)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    func sendPasswordResetLink(email: String) {
       
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showAlert(message: "Error sending reset email: \(error.localizedDescription)")
                return
            }
            
            self.showAlert(message: "Password reset email sent successfully. Please check your inbox.")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Password Reset", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
