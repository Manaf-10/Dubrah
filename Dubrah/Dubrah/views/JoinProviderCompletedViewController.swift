//
//  JoinProviderCompletedViewController.swift
//  Dubrah
//
//  Created by user287722 on 1/3/26.
//

import UIKit

class JoinProviderCompletedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func BackToSettingTapped(_ sender: Any) {
        // Use navigationController to pop to a specific view controller
        if let navigationController = self.navigationController {
            // Check if there are enough view controllers to pop
            if navigationController.viewControllers.count > 4 {
                // Pop to the previous view controller (or target view controller)
                let targetViewController = navigationController.viewControllers[navigationController.viewControllers.count - 4]
                navigationController.popToViewController(targetViewController, animated: true)
            }
        }
    }

}
