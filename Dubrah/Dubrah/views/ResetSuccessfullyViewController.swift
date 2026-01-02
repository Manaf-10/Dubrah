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
        
        if let navigationController = self.navigationController {
            // Check if there are enough view controllers to pop
            if navigationController.viewControllers.count > 5 {
                // Pop to the previous view controller (or target view controller)
                let targetViewController = navigationController.viewControllers[navigationController.viewControllers.count - 5]
                navigationController.popToViewController(targetViewController, animated: true)
            }
        }
    }
}
