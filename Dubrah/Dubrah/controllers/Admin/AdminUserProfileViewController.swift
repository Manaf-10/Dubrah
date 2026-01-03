//
//  UserProfileViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

class AdminUserProfileViewController: AdminBaseViewController,
UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var certificatesCollectionView: UICollectionView!
    
    @IBOutlet weak var portfolioCollectionView: UICollectionView!
    
    
    @IBOutlet weak var takeActionButton: UIButton!

    private var profile: UserProfileDetails?
    private var certificates: [Certificate] = []
    private var portfolio: [PortfolioItem] = []
    var user: User?



    override func viewDidLoad() {
        super.viewDidLoad()

        guard let user else {
             fatalError("❌ UserProfileViewController opened without User")
         }

         buildProfile(from: user)
         setupCollections()
         bindData()
     }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == certificatesCollectionView {
            return certificates.count
        } else {
            return portfolio.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == certificatesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CertificateCell", for: indexPath) as! CertificateCollectionViewCell
            cell.setup(with: certificates[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PortfolioCell", for: indexPath) as! PortfolioCollectionViewCell
            cell.setup(with: portfolio[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == certificatesCollectionView {
            return CGSize(width: 110, height: 110)   // square cards
        } else {
            return CGSize(width: 200, height: 170)   // portfolio card with labels
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }



    
    private func buildProfile(from user: User) {
        profile = UserProfileDetails(
            avatar: user.avatar,
            username: user.username,
            role: user.role,
            description: "This description will later come from Firebase"
        )

        certificates = Certificate.mock
        portfolio = PortfolioItem.mock
    }


    
    private func setupCollections() {
        certificatesCollectionView.delegate = self
        certificatesCollectionView.dataSource = self

        portfolioCollectionView.delegate = self
        portfolioCollectionView.dataSource = self
    }

    
    private func bindData() {
        guard let profile else { return }

        avatarImageView.image = profile.avatar
        usernameLabel.text = profile.username
        roleLabel.text = profile.role
        descriptionLabel.text = profile.description
    }




}
