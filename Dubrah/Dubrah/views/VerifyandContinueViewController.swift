import UIKit
import FirebaseAuth

class VerifyandContinueViewController: UIViewController {

    var email: String!
    @IBOutlet weak var VACbtn: UIButton!
    @IBOutlet weak var resendEmailButton: UIButton!

    
    var canResendEmail = true

    override func viewDidLoad() {
        super.viewDidLoad()

        VACbtn.layer.cornerRadius = 12.0
        VACbtn.clipsToBounds = true
        
        
        resendEmailButton.isEnabled = true
        resendEmailButton.layer.cornerRadius = 12.0
        resendEmailButton.clipsToBounds = true
    }

    @IBAction func verifyButtonTapped(_ sender: UIButton) {
        Auth.auth().currentUser?.reload(completion: { error in
            if let error = error {
                print("Error reloading user session: \(error.localizedDescription)")
                return
            }

            
            if Auth.auth().currentUser?.isEmailVerified == true {
                // Proceed to the next screen
                self.performSegue(withIdentifier: "GoToSettingUpAccount", sender: nil)
            } else {
                self.showAlert(message: "Please verify your email before proceeding.")
            }
        })
    }

    @IBAction func resendEmailButtonTapped(_ sender: UIButton) {
       
        guard canResendEmail else {
            showAlert(message: "Please wait before resending the email.")
            return
        }

        guard let user = Auth.auth().currentUser else {
            showAlert(message: "No user is logged in.")
            return
        }

       
        canResendEmail = false
        resendEmailButton.isEnabled = false

        user.sendEmailVerification { error in
            if let error = error {
                print("Error sending verification email: \(error.localizedDescription)")
                self.showAlert(message: "Error sending verification email.")
            } else {
                print("Verification email sent successfully.")
                self.showAlert(message: "A new verification email has been sent to \(user.email ?? "your email"). Please check your inbox.")
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                    self.canResendEmail = true
                    self.resendEmailButton.isEnabled = true
                }
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
