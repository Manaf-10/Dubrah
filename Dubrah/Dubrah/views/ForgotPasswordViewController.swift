//
//  ForgotPasswordViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/5/25.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    
    @IBOutlet weak var SendResetCodebtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SendResetCodebtn.layer.cornerRadius = 12
        SendResetCodebtn.clipsToBounds = true

        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

   

}
