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
         
        continueButton.isEnabled = false
        continueButton.layer.cornerRadius = 12.0
        continueButton.clipsToBounds = true
   
    }

    
    @IBAction func designButtonTapped(_ sender: UIButton) {
        toggleSkillSelection(skill: "Design", button: sender)
    }
    
    
    @IBAction func developmentButtonTapped(_ sender: UIButton) {
        toggleSkillSelection(skill: "Development", button: sender)
    }

    
    @IBAction func photographyButtonTapped(_ sender: UIButton) {
        toggleSkillSelection(skill: "Photography", button: sender)
    }

    
    @IBAction func tutoringButtonTapped(_ sender: UIButton) {
        toggleSkillSelection(skill: "Tutoring", button: sender)
    }

    
    func toggleSkillSelection(skill: String, button: UIButton) {
        if selectedSkills.contains(skill) {
            
            selectedSkills.removeAll { $0 == skill }
            button.backgroundColor = .red
        } else {
            
            selectedSkills.append(skill)
            button.backgroundColor = .green
        }

        
        continueButton.isEnabled = !selectedSkills.isEmpty
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        
        saveSkillsAndInterests()
    }

    func saveSkillsAndInterests() {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "User is not authenticated")
            return
        }

        
        if !selectedSkills.isEmpty {
            let userRef = Firestore.firestore().collection("user").document(currentUser.uid)
            userRef.updateData([
                "interests": selectedSkills
            ]) { error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                
                self.performSegue(withIdentifier: "GoToNextPage", sender: nil)
            }
        } else {
            
            self.performSegue(withIdentifier: "GoToNextPage", sender: nil)
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

