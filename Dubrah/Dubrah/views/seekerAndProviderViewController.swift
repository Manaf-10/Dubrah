//
//  seekerAndProviderViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/27/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class seekerAndProviderViewController: UIViewController {

    @IBOutlet weak var ProviderBtn: UIButton!
    @IBOutlet weak var SeekerBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func seekerButtonTapped(_ sender: UIButton) {
            // Update user's role to "seeker" in Firestore
            updateRoleInFirestore(role: "seeker")
            
            // Navigate to home page for Seeker
            navigateToHomePage()
        }
        
        @IBAction func providerButtonTapped(_ sender: UIButton) {
            // Update user's role to "provider" in Firestore
            updateRoleInFirestore(role: "seeker")
            
            // Navigate to Verify Your Identity page for Provider
            performSegue(withIdentifier: "ShowVerifyIdentity", sender: nil)
        }
        
        func updateRoleInFirestore(role: String) {
            // Update the user's role in Firestore
            let userRef = Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid)
            userRef.updateData([
                "role": role // Set the role to "seeker" or "provider"
            ]) { error in
                if let error = error {
                    print("Error updating role: \(error.localizedDescription)")
                } else {
                    print("Role updated to \(role) successfully!")
                }
            }
        }
        
        func navigateToHomePage() {
        
        }
    }


