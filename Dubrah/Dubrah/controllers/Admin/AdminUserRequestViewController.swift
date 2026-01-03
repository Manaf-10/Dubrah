//
//  UserRequestViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 01/01/2026.
//

import UIKit
import FirebaseFirestore


class AdminUserRequestViewController: AdminBaseViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var btnsView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 🔑 REQUIRED INPUT
     var request: UserRequest!
    
    private let db = Firestore.firestore()

     private var documents: [VerificationDocument] = []

     override func viewDidLoad() {
         super.viewDidLoad()

         guard request != nil else {
                 print("❌ ERROR: No request provided to AdminUserRequestViewController")
                 navigationController?.popViewController(animated: false)
                 return
             }
             
             guard !request.documents.isEmpty else {
                 print("⚠️ WARNING: Request has no documents")
                 // Continue anyway, just show empty collection view
                 documents = []
                 setupNavigation()
                 setupCollectionView()
                 return
             }

             documents = request.documents

             setupNavigation()
             setupCollectionView()

             navigationController?.interactivePopGestureRecognizer?.delegate = self
             navigationController?.interactivePopGestureRecognizer?.isEnabled = true
         }

     // MARK: - Setup
     private func setupNavigation() {
         setNavigationTitleWithBtn(
             title: "View Details",
             imageName: "Back-Btn",
             target: self,
             action: #selector(backToHome)
         )
     }

     private func setupCollectionView() {
         collectionView.delegate = self
         collectionView.dataSource = self
         collectionView.backgroundColor = .clear
         collectionView.allowsSelection = false
     }

     // MARK: - CollectionView DataSource
     func collectionView(_ collectionView: UICollectionView,
                         numberOfItemsInSection section: Int) -> Int {
         documents.count
     }

     func collectionView(_ collectionView: UICollectionView,
                         cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

         let cell = collectionView.dequeueReusableCell(
             withReuseIdentifier: "VerifyDocCell",
             for: indexPath
         ) as! VerifyDocsCollectionViewCell

         let doc = documents[indexPath.item]
         cell.setupCell(document: doc)

         return cell
     }

     // MARK: - Layout
     func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAt indexPath: IndexPath) -> CGSize {
         CGSize(width: 120, height: 120)
     }

     func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         12
     }

     // MARK: - Actions
     @IBAction func approveTapped(_ sender: UIButton) {
         showApprovePopup()
     }

     @IBAction func rejectTapped(_ sender: UIButton) {
         showRejectPopup()
     }

     private func showApprovePopup() {
         let popup = ReusablePopupViewController(
             config: .confirm(
                 title: "Approve Request",
                 message: "Are you sure you want to approve this user?",
                 confirmTitle: "Approve",
                 cancelTitle: "Cancel",
                 onConfirm: { [weak self] in
                     self?.approveRequest()
                 }
             )
         )
         present(popup, animated: true)
     }

     private func showRejectPopup() {
         let popup = ReusablePopupViewController(
             config: .confirm(
                 title: "Reject Request",
                 message: "Are you sure you want to reject this user?",
                 confirmTitle: "Reject",
                 cancelTitle: "Cancel",
                 onConfirm: { [weak self] in
                     self?.rejectRequest()
                 }
             )
         )
         present(popup, animated: true)
     }

    private func approveRequest() {
        guard let userId = request?.userId else { return }
        
        print("✅ Approving request for user: \(userId)")
        
        // Update user document: set verified = true
        db.collection("user")
            .document(userId)
            .updateData(["verified": true]) { [weak self] error in
                
                if let error = error {
                    print("❌ Error approving: \(error)")
                    self?.showErrorAlert(message: "Failed to approve request")
                    return
                }
                
                print("✅ User verified successfully")
                self?.showSuccessAlert(message: "Request approved!") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
    }

    private func rejectRequest() {
        guard let userId = request?.userId else { return }
        
        print("❌ Rejecting request for user: \(userId)")
        
        // Update user: change role back to "seeker" and keep verified = false
        db.collection("user")
            .document(userId)
            .updateData([
                "role": "seeker",
                "verified": false
            ]) { [weak self] error in
                
                if let error = error {
                    print("❌ Error rejecting: \(error)")
                    self?.showErrorAlert(message: "Failed to reject request")
                    return
                }
                
                print("✅ Request rejected successfully")
                self?.showSuccessAlert(message: "Request rejected") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
    }

    // Helper methods
    private func showSuccessAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

     // MARK: - Tab Bar
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         hideTabBar(animated: animated)
     }

     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         showTabBar()
     }

     // MARK: - Layout
     override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()

         cardView.layer.cornerRadius = 24
         cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

         btnsView.layer.cornerRadius = 24
         btnsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
     }

     @objc private func backToHome() {
         navigationController?.popViewController(animated: true)
     }
 }
