//
//  ProfileViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 01/01/2026.
//

import UIKit

class AdminProfileViewController: AdminBaseViewController {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var profileEditBtn: UIButton!
    @IBOutlet weak var profileLogoutBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle("Profile")
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profileImg.clipsToBounds = true
        profileImg.layer.cornerRadius = profileImg.frame.width / 2
        profileImg.layer.borderWidth = 2
        profileImg.layer.borderColor = UIColor(hex: "#2358D2").cgColor

    }
}

