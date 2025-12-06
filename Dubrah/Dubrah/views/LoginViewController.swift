//
//  LoginViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/5/25.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
   
    
    @IBOutlet weak var emailTextFeild: UITextField!
    @IBOutlet weak var SigninBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextFeild.delegate = self
        
        SigninBtn.layer.cornerRadius = 12
        SigninBtn.clipsToBounds = true
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
}
