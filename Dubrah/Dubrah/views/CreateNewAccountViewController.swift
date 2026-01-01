//
//  CreateNewAccountViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/25/25.
//

import UIKit
import FirebaseAuth

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
        
        // Proceed to the next screen after email validation
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
            
            // Send email verification
            authResult?.user.sendEmailVerification { error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                // Proceed to the next page
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
