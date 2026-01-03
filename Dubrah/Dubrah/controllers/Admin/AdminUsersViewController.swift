//
//  UsersViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 02/01/2026.
//

import UIKit

class AdminUsersViewController: AdminBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var users: [User] = []

       override func viewDidLoad() {
           super.viewDidLoad()

           setupNavigationTitle("Users")
           setupNavigationAppearance()

           collectionView.delegate = self
           collectionView.dataSource = self

           loadUsers()
       }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }


       private func loadUsers() {
           // For now (mock data)
           users = User.mockUsers
           collectionView.reloadData()
       }

       // MARK: - CollectionView DataSource

       func collectionView(_ collectionView: UICollectionView,
                           numberOfItemsInSection section: Int) -> Int {
           return users.count
       }

       func collectionView(_ collectionView: UICollectionView,
                           cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

           let cell = collectionView.dequeueReusableCell(
               withReuseIdentifier: "userCell",
               for: indexPath
           ) as! UsersCollectionViewCell

           cell.setupCell(with: users[indexPath.item])
           return cell
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let user = users[indexPath.item]

        let vc = UIStoryboard(name: "Users", bundle: nil)
            .instantiateViewController(withIdentifier: "UserProfileViewController")
            as! AdminUserProfileViewController

        vc.user = user   // 👈 MUST be set before push

        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let padding: CGFloat = 16      // left + right
        let spacing: CGFloat = 12      // space between cells
        let totalSpacing = padding + spacing

        let availableWidth = collectionView.bounds.width - totalSpacing
        let cellWidth = availableWidth / 2   // 👈 2 columns

        return CGSize(width: cellWidth, height: 200)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 12
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 12
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
    }
  


   }
