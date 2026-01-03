//
//  UserProfileViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit
import FirebaseFirestore

class AdminUserProfileViewController: AdminBaseViewController,
UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var certificatesCollectionView: UICollectionView!
    
    @IBOutlet weak var portfolioCollectionView: UICollectionView!
    
    
    @IBOutlet weak var takeActionButton: UIButton!

    var userId: String!
      
      private let db = Firestore.firestore()
      private var user: AppUser?
      private var portfolio: [PortfolioItem] = []
      private var certificates: [Certificate] = []

      override func viewDidLoad() {
          super.viewDidLoad()

          guard userId != nil else {
              print("No userId provided!")
              return
          }

          setupNavigation()
//          setupNavigationTitle("User Profile")
//          setupNavigationAppearance()
          
          setupCollections()
          fetchUser()
      }
    
    private func setupNavigation() {
        setNavigationTitleWithBtn(
            title: "View Details",
            imageName: "Back-Btn",
            target: self,
            action: #selector(backToHome)
        )
    }
      
      private func setupCollections() {
          certificatesCollectionView.delegate = self
          certificatesCollectionView.dataSource = self
          portfolioCollectionView.delegate = self
          portfolioCollectionView.dataSource = self
          
          // Make avatar circular
          avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
          avatarImageView.clipsToBounds = true
      }
      
      override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
      }
      
      private func fetchUser() {
          db.collection("user")
              .document(userId)
              .getDocument { [weak self] snap, error in
                  
                  if let error = error {
                      print("❌ Error fetching user: \(error)")
                      return
                  }

                  guard
                      let snap = snap,
                      snap.exists,
                      let data = snap.data(),
                      let user = AppUser(id: snap.documentID, data: data)
                  else {
                      print("❌ User document not found or invalid")
                      return
                  }

                  self?.user = user
                  self?.bindUser()
                  self?.loadPortfolio()
              }
      }
      
      private func bindUser() {
          guard let user = user else { return }

          usernameLabel.text = user.fullName
          roleLabel.text = user.role
          descriptionLabel.text = "Username: @\(user.userName)"

          if let url = user.profilePicture {
              avatarImageView.loadFromUrl(url)
          } else {
              avatarImageView.image = UIImage(named: "Log-Profile")
          }
      }
      
      private func loadPortfolio() {
          // TODO: Fetch from ProviderDetails collection
          portfolio = PortfolioItem.mock
          certificates = Certificate.mock
          
          portfolioCollectionView.reloadData()
          certificatesCollectionView.reloadData()
      }
      
      // MARK: - CollectionView DataSource
      
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
              return CGSize(width: 110, height: 110)
          } else {
              return CGSize(width: 200, height: 170)
          }
      }
      
      func collectionView(_ collectionView: UICollectionView,
                          layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 12
      }
    
    @objc private func backToHome() {
        navigationController?.popViewController(animated: true)
    }
  }
