//
//  CreateNewPassViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/25/25.
//

import UIKit

class CreateNewPassViewController: UIViewController {

    @IBOutlet weak var saveNewPassbtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        saveNewPassbtn.layer.cornerRadius = 12
        saveNewPassbtn.clipsToBounds = true
    }
    

   
}
