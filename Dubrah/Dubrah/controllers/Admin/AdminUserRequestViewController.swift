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
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
 
        var request: UserRequest!
        
        private let db = Firestore.firestore()
        private let logsService = AdminLogsService()
        private var documents: [VerificationDocument] = []

        override func viewDidLoad() {
            super.viewDidLoad()

            guard request != nil else {
                print("❌ ERROR: No request provided")
                navigationController?.popViewController(animated: false)
                return
            }

            documents = request.documents

            setupNavigation()
            setupCollectionView()
            bindUserData()

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
            collectionView.allowsSelection = false  // ✅ Disable cell selection (we use tap gesture instead)
        }
        
        private func bindUserData() {
            nameLabel.text = request.name
            roleLabel.text = request.role
            
            if let avatarUrl = request.profilePictureUrl {
                avatarImageView.loadFromUrl(avatarUrl)
            } else {
                avatarImageView.image = UIImage(named: "Log-Profile")
            }
            
            avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
            avatarImageView.clipsToBounds = true
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
            
            cardView.layer.cornerRadius = 24
            cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

            btnsView.layer.cornerRadius = 24
            btnsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
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
            
            // ✅ Handle image tap from cell
            cell.onImageTapped = { [weak self] image in
                self?.showImagePreview(image: image)
            }

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

        // MARK: - Image Preview
        
        // ✅ Single image preview method
        private func showImagePreview(image: UIImage) {
            let previewVC = ImagePreviewViewController(image: image)
            present(previewVC, animated: true)
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
        
        db.collection("user")
            .document(userId)
            .updateData(["verified": true]) { [weak self] error in
                
                if let error = error {
                    print("❌ Error approving: \(error)")
                    self?.showResultPage(
                        type: .error,
                        message: "Something went wrong, try again later.."
                    )
                    return
                }
                
                self?.logsService.logAdminAction(
                    action: .adminApprovedProvider,
                    targetUsername: self?.request.name
                )
                
                print("✅ User verified successfully")
                self?.showResultPage(
                    type: .success,
                    message: "User have been successfully accepted to be provider"
                ) {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
    }

    private func rejectRequest() {
        guard let userId = request?.userId else { return }
        
        print("❌ Rejecting request for user: \(userId)")
        
        db.collection("user")
            .document(userId)
            .updateData([
                "role": "seeker",
                "verified": false
            ]) { [weak self] error in
                
                if let error = error {
                    print("❌ Error rejecting: \(error)")
                    self?.showResultPage(
                        type: .error,
                        message: "Something went wrong, try again later.."
                    )
                    return
                }
                
                self?.logsService.logAdminAction(
                    action: .adminRejectedProvider,
                    targetUsername: self?.request.name
                )
                
                print("✅ Request rejected successfully")
                self?.showResultPage(
                    type: .success,
                    message: "User request has been rejected successfully"
                ) {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
    }

    private func showResultPage(type: ResultType, message: String, onDismiss: (() -> Void)? = nil) {
        let resultVC = ResultViewController(type: type, message: message, onDismiss: onDismiss)
        present(resultVC, animated: true)
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

    @objc private func backToHome() {
        navigationController?.popViewController(animated: true)
    }
}
