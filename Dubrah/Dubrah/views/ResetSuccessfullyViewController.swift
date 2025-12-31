//
//  ResetSuccessfullyViewController.swift
//  Dubrah
//
//  Created by user287722 on 12/29/25.
//

import UIKit

class ResetSuccessfullyViewController: UIViewController {

    @IBOutlet weak var backToSignInBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        backToSignInBtn.layer.cornerRadius = 12
        backToSignInBtn.clipsToBounds = true
        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        // Navigate back to the sign-in screen
                self.performSegue(withIdentifier: "LoginViewController", sender: self)
    }
    
    

}
