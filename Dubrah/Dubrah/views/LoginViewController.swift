//
//  LoginViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/5/25.
//

import UIKit

class LoginViewController: UIViewController {
   
    @IBOutlet weak var SigninBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SigninBtn.layer.cornerRadius = 12
        SigninBtn.clipsToBounds = true
        
    }
   
    

    
}
