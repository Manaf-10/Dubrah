//
//  SkillsViewController.swift
//  Dubrah
//
//  Created by user287722 on 12/31/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SkillsViewController: UIViewController {
    
    @IBOutlet weak var designButton: UIButton!
       @IBOutlet weak var developmentButton: UIButton!
       @IBOutlet weak var photographyButton: UIButton!
       @IBOutlet weak var tutoringButton: UIButton!
       @IBOutlet weak var continueButton: UIButton!

    var selectedSkills: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func skillButtonTapped(_ sender: UIButton) {
            if selectedSkills.contains(sender.titleLabel!.text!) {
                selectedSkills.removeAll { $0 == sender.titleLabel!.text! }
                sender.backgroundColor = .red
            } else {
                selectedSkills.append(sender.titleLabel!.text!)
                sender.backgroundColor = .green
            }
        }
        
        @IBAction func continueButtonTapped(_ sender: UIButton) {
            saveSkillsAndInterests()
        }
        
        func saveSkillsAndInterests() {
            let userRef = Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid)
            userRef.updateData([
                "interests": selectedSkills
            ]) { error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                // Proceed to the next page
                self.performSegue(withIdentifier: "ShowHowToGetStarted", sender: nil)
            }
        }
        
        func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }


