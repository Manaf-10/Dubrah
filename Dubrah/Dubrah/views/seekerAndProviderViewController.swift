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

       
    }
    

    @IBAction func seekerButtonTapped(_ sender: UIButton) {
            
            updateRoleInFirestore(role: "seeker")
            
            
            navigateToHomePage()
        }
        
        @IBAction func providerButtonTapped(_ sender: UIButton) {
            
            updateRoleInFirestore(role: "seeker")
            
            
            performSegue(withIdentifier: "ShowVerifyIdentity", sender: nil)
        }
        
        func updateRoleInFirestore(role: String) {
            
            let userRef = Firestore.firestore().collection("user").document(Auth.auth().currentUser!.uid)
            userRef.updateData([
                "role": role
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


