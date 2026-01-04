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
    private let logsService = AdminLogsService()
    private var user: AppUser?
    private var portfolio: [PortfolioItem] = []
    private var certificates: [Certificate] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard userId != nil else {
            print("❌ No userId provided!")
            navigationController?.popViewController(animated: false)
            return
        }

        setupNavigation()
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
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.clipsToBounds = true
    }
      
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
      
    private func fetchUser() {
        print("📥 Fetching user: \(userId ?? "nil")")
        
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

                print("✅ User fetched: \(user.fullName)")
                self?.user = user
                self?.bindUser()
                self?.loadPortfolio()
            }
    }
      
    private func bindUser() {
        guard let user = user else { return }

        usernameLabel.text = user.fullName
        roleLabel.text = user.role.capitalized
//        descriptionLabel.text = "Email: \(user.email)"

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
    
    // MARK: - Take Action Button
    
    @IBAction func takeActionTapped(_ sender: UIButton) {
        showTakeActionPanel()
    }
    
    private func showTakeActionPanel() {
        let panel = ReusableBottomPanelViewController(
            config: BottomPanelConfig(actions: [
                BottomPanelAction(title: "Unverify User", style: .outline) { [weak self] in
                    self?.showUnverifyPopup()
                },
                BottomPanelAction(title: "Suspend User", style: .outline) { [weak self] in
                    self?.showSuspendPopup()
                },
                BottomPanelAction(title: "Ban User", style: .destructive) { [weak self] in
                    self?.showBanPopup()
                }
            ])
        )
        present(panel, animated: true)
    }
    
    // MARK: - Popups
    
    private func showUnverifyPopup() {
        let popup = ReusablePopupViewController(
            config: .confirm(
                title: "Unverify User",
                message: "Are you sure you want to unverify this user?",
                confirmTitle: "Unverify",
                cancelTitle: "Cancel",
                onConfirm: { [weak self] in
                    self?.unverifyUser()
                }
            )
        )
        present(popup, animated: true)
    }
    
    private func showSuspendPopup() {
        let popup = ReusablePopupViewController(
            config: .suspension(
                title: "Select The Suspension Period",
                message: nil,
                options: ["8 Hours", "24 Hours", "3 Days", "1 Week", "1 Month"],
                onConfirm: { [weak self] duration in
                    self?.suspendUser(duration: duration)
                }
            )
        )
        present(popup, animated: true)
    }
    
    private func showBanPopup() {
        let popup = ReusablePopupViewController(
            config: .confirm(
                title: "Ban User",
                message: "This action is permanent. Are you sure?",
                confirmTitle: "Ban",
                cancelTitle: "Cancel",
                onConfirm: { [weak self] in
                    self?.banUser()
                }
            )
        )
        present(popup, animated: true)
    }
    
    // MARK: - Firebase Actions
    
    private func unverifyUser() {
        guard let userId = userId else { return }
        
        print("🚫 Unverifying user: \(userId)")
        
        db.collection("user")
            .document(userId)
            .updateData(["verified": false]) { [weak self] error in
                
                if let error = error {
                    print("❌ Error: \(error)")
                    self?.showResultPage(type: .error, message: "Failed to unverify user")
                    return
                }
                
                // Log the action
                self?.logsService.logAdminAction(
                    action: .adminUnverifiedUser,
                    targetUsername: self?.user?.fullName
                )
                
                self?.showResultPage(type: .success, message: "User has been unverified successfully") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
    }
    
    private func suspendUser(duration: String) {
        guard let userId = userId else { return }
        
        print("⏳ Suspending user for \(duration)")
        
        var days = 0
        switch duration {
        case "8 Hours": days = 0  // Will use hours below
        case "24 Hours": days = 1
        case "3 Days": days = 3
        case "1 Week": days = 7
        case "1 Month": days = 30
        default: days = 1
        }
        
        var suspendedUntil: Date
        if duration == "8 Hours" {
            suspendedUntil = Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date()
        } else {
            suspendedUntil = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        }
        
        db.collection("user")
            .document(userId)
            .updateData([
                "suspended": true,
                "suspendedUntil": Timestamp(date: suspendedUntil)
            ]) { [weak self] error in
                
                if let error = error {
                    print("❌ Error: \(error)")
                    self?.showResultPage(type: .error, message: "Failed to suspend user")
                    return
                }
                
                // Log the action
                self?.logsService.logAdminAction(
                    action: .adminSuspendedUser,
                    targetUsername: self?.user?.fullName,
                    details: "Suspended for \(duration)"
                )
                
                self?.showResultPage(type: .success, message: "User has been suspended for \(duration)") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
    }
    
    private func banUser() {
        guard let userId = userId else { return }
        
        print("⛔ Banning user: \(userId)")
        
        db.collection("user")
            .document(userId)
            .updateData([
                "banned": true,
                "verified": false
            ]) { [weak self] error in
                
                if let error = error {
                    print("❌ Error: \(error)")
                    self?.showResultPage(type: .error, message: "Failed to ban user")
                    return
                }
                
                // Log the action
                self?.logsService.logAdminAction(
                    action: .adminBannedUser,
                    targetUsername: self?.user?.fullName
                )
                
                self?.showResultPage(type: .success, message: "User has been banned permanently") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
    }
    
    private func showResultPage(type: ResultType, message: String, onDismiss: (() -> Void)? = nil) {
        let resultVC = ResultViewController(type: type, message: message, onDismiss: onDismiss)
        present(resultVC, animated: true)
    }
    
    @objc private func backToHome() {
        navigationController?.popViewController(animated: true)
    }
}
