//
//  ViewController.swift
//  Dubrah
//
//  Created by Abdulla Mohd Shams on 30/11/2025.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var GetStartedButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        GetStartedButton.layer.cornerRadius = 12.0
        GetStartedButton.clipsToBounds = true
        view.backgroundColor = UIColor(hex: "#F8FAFC")
    }


}

