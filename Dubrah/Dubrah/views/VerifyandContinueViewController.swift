import UIKit
import FirebaseAuth

class VerifyandContinueViewController: UIViewController {

    var email: String!
    @IBOutlet weak var VACbtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        VACbtn.layer.cornerRadius = 12.0
        VACbtn.clipsToBounds = true

    }

    @IBAction func verifyButtonTapped(_ sender: UIButton) {
        // Reload the current user session to ensure we have the latest email verification status
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

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

