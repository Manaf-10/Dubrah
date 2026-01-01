import UIKit
import FirebaseFirestore
import FirebaseAuth

class SkillsViewController: UIViewController {

    @IBOutlet weak var designButton: UIButton!
    @IBOutlet weak var developmentButton: UIButton!
    @IBOutlet weak var photographyButton: UIButton!
    @IBOutlet weak var tutoringButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!

    var selectedSkills: [String] = []  // Array to hold selected skills

    override func viewDidLoad() {
        super.viewDidLoad()
        // Disable the continue button until at least one skill is selected
        continueButton.isEnabled = false
        continueButton.layer.cornerRadius = 12.0
        continueButton.clipsToBounds = true
   
    }

    // Function for design button
    @IBAction func designButtonTapped(_ sender: UIButton) {
        toggleSkillSelection(skill: "Design", button: sender)
    }
    
    // Function for development button
    @IBAction func developmentButtonTapped(_ sender: UIButton) {
        toggleSkillSelection(skill: "Development", button: sender)
    }

    // Function for photography button
    @IBAction func photographyButtonTapped(_ sender: UIButton) {
        toggleSkillSelection(skill: "Photography", button: sender)
    }

    // Function for tutoring button
    @IBAction func tutoringButtonTapped(_ sender: UIButton) {
        toggleSkillSelection(skill: "Tutoring", button: sender)
    }

    // Generalized function to handle button tap and update selected skills
    func toggleSkillSelection(skill: String, button: UIButton) {
        if selectedSkills.contains(skill) {
            // If the skill is already selected, remove it and set the button color to red
            selectedSkills.removeAll { $0 == skill }
            button.backgroundColor = .red
        } else {
            // Add the skill to the selected list and change the button color to green
            selectedSkills.append(skill)
            button.backgroundColor = .green
        }

        // Enable the continue button only if at least one skill is selected
        continueButton.isEnabled = !selectedSkills.isEmpty
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        // Save the selected skills to Firestore
        saveSkillsAndInterests()
    }

    func saveSkillsAndInterests() {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "User is not authenticated")
            return
        }

        // Save the selected skills (interests) to Firestore only if there are selected skills
        if !selectedSkills.isEmpty {
            let userRef = Firestore.firestore().collection("user").document(currentUser.uid)
            userRef.updateData([
                "interests": selectedSkills  // Save the skills to Firestore
            ]) { error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                // Successfully saved, proceed to the next page
                self.performSegue(withIdentifier: "GoToNextPage", sender: nil)
            }
        } else {
            // If no skills are selected, proceed without saving anything
            self.performSegue(withIdentifier: "GoToNextPage", sender: nil)
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

