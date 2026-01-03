import UIKit
import FirebaseAuth

class VerifyandContinueViewController: UIViewController {

    var email: String!
    @IBOutlet weak var VACbtn: UIButton!
    @IBOutlet weak var resendEmailButton: UIButton!

    // Variable to track if resend action is allowed
    var canResendEmail = true

    override func viewDidLoad() {
        super.viewDidLoad()

        VACbtn.layer.cornerRadius = 12.0
        VACbtn.clipsToBounds = true
        
        // Disable the Resend Email button initially
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

            // Now check if the email is verified after reload
            if Auth.auth().currentUser?.isEmailVerified == true {
                // Proceed to the next screen
                self.performSegue(withIdentifier: "GoToSettingUpAccount", sender: nil)
            } else {
                self.showAlert(message: "Please verify your email before proceeding.")
            }
        })
    }

    @IBAction func resendEmailButtonTapped(_ sender: UIButton) {
        // Check if we are currently allowed to send the verification email
        guard canResendEmail else {
            showAlert(message: "Please wait before resending the email.")
            return
        }

        guard let user = Auth.auth().currentUser else {
            showAlert(message: "No user is logged in.")
            return
        }

        // Disable the button to prevent spamming the resend request
        canResendEmail = false
        resendEmailButton.isEnabled = false

        user.sendEmailVerification { error in
            if let error = error {
                print("Error sending verification email: \(error.localizedDescription)")
                self.showAlert(message: "Error sending verification email.")
            } else {
                print("Verification email sent successfully.")
                self.showAlert(message: "A new verification email has been sent to \(user.email ?? "your email"). Please check your inbox.")
                
                // Re-enable the button after a cooldown period (e.g., 60 seconds)
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
