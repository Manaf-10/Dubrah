//
//  ProviderCompleteViewController.swift
//  Dubrah
//
//  Created by user287722 on 1/4/26.
//

import UIKit

class ProviderCompleteViewController: UIViewController {

    @IBOutlet weak var goTOHomeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        goTOHomeBtn.layer.cornerRadius = 12
        goTOHomeBtn.clipsToBounds = true
    }
    

    @IBAction func goToHomeTapped(_ sender: Any) {
        performSegue(withIdentifier: "GoTONext", sender: nil)
    }
    

}
