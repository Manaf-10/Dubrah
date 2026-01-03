//
//  ReviewSuccessViewController.swift
//  Dubrah
//
//  Created by Ali on 31/12/2025.
//

import UIKit

class ReviewSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }

    @IBAction func backTapped(_ sender: UIButton) {
        guard let nav = navigationController else { return }

        for viewController in nav.viewControllers {
            if viewController is OrderHistoryViewController {
                nav.popToViewController(viewController, animated: true)
                return
            }
        }
        nav.popViewController(animated: true)
    }

}
