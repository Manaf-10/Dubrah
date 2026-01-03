//
//  UserReportViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 02/01/2026.
//

import UIKit

class AdminUserReportViewController: AdminBaseViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var btnsView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
       @IBOutlet weak var usernameLabel: UILabel!
       @IBOutlet weak var emailLabel: UILabel!
       @IBOutlet weak var typeButton: UIButton!
       @IBOutlet weak var titleLabel: UILabel!
       @IBOutlet weak var descriptionLabel: UILabel!
       @IBOutlet weak var reportedUsernameLabel: UILabel!
    @IBOutlet weak var reportedAvatarImg : UIImageView!

    var report: Report?


       override func viewDidLoad() {
           super.viewDidLoad()
           configureUI()
           bindData()
           
           
           // Enable swipe-back
           navigationController?.interactivePopGestureRecognizer?.delegate = self
           navigationController?.interactivePopGestureRecognizer?.isEnabled = true
           
           setNavigationTitleWithBtn(
               title: "View Details",
               imageName: "Back-Btn",
               target: self,
               action: #selector(backToHome)
           )
       }
    
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           //  ALWAYS hide tab bar when this page appears
           hideTabBar(animated: animated)
       }
    
    
     override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         
         // Handle interactive pop gesture cancellation
         if let coordinator = transitionCoordinator {
             coordinator.notifyWhenInteractionChanges { [weak self] context in
                 if context.isCancelled {
                     // User cancelled swipe → stay on this page → keep hidden
                     self?.hideTabBar()
                 }
             }
         } else {
             // Ensure hidden if no transition
             hideTabBar()
         }
     }

     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
         // Show tab bar when leaving (unless cancelled)
         if let coordinator = transitionCoordinator {
             coordinator.animate(alongsideTransition: nil) { [weak self] context in
                 if !context.isCancelled {
                     // Pop completed → show tab bar
                     self?.showTabBar()
                 }
             }
         } else {
             // Direct dismissal
             showTabBar()
         }
     }

    

       private func configureUI() {
           
           avatarImageView.clipsToBounds = true

           typeButton.isUserInteractionEnabled = false
           typeButton.layer.cornerRadius = 9
           typeButton.layer.borderWidth = 1
           typeButton.layer.borderColor = UIColor(named: "PrimaryBlue")?.cgColor
           typeButton.setTitleColor(.systemBlue, for: .normal)
           typeButton.titleLabel?.font = .systemFont(ofSize: 11, weight: .medium)
       }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        
        
        cardView.layer.cornerRadius = 24
        cardView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        cardView.layer.masksToBounds = true
        
        btnsView.layer.cornerRadius = 24
        btnsView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        btnsView.layer.masksToBounds = true
    }

    private func bindData() {
        guard let report else {
            assertionFailure("❌ UserReportViewController opened without report")
            return
        }

        avatarImageView.image = report.avatar
        usernameLabel.text = report.username
        emailLabel.text = report.email
        typeButton.setTitle(report.type, for: .normal)
        titleLabel.text = report.title
        descriptionLabel.text = report.description
        reportedUsernameLabel.text = report.reportedUser
        reportedAvatarImg.image = report.reportedAvatar
    }
    
    @IBAction func takeActionTapped(_ sender: UIButton) {
        showTakeActionPanel()
    }
    
    
    @objc private func backToHome() {
        navigationController?.popViewController(animated: true)
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

    
    private func showUnverifyPopup() {
        let popup = ReusablePopupViewController(
            config: PopupConfig.confirm(
                title: "Unverify User",
                message: "Are you sure you want to unverify this user?",
                confirmTitle: "Unverify",
                cancelTitle: "Cancel",
                onConfirm: { [weak self] in self?.unverifyUser() }
            )
        )
        present(popup, animated: true)
    }

    private func showBanPopup() {
        let popup = ReusablePopupViewController(
            config: PopupConfig.confirm(
                title: "Ban User",
                message: "This action is permanent. Are you sure?",
                confirmTitle: "Ban",
                cancelTitle: "Cancel",
                onConfirm: { [weak self] in self?.banUser() }
            )
        )
        present(popup, animated: true)
    }

    private func showSuspendPopup() {
        let popup = ReusablePopupViewController(
            config: PopupConfig.suspension(
                title: "Suspend User",
                message: "Select suspension duration",
                options: ["24 Hours", "3 Days", "7 Days", "1 Month", "Permanent"],
                onConfirm: { [weak self] duration in
                    self?.suspendUser(duration: duration)
                }
            )
        )
        present(popup, animated: true)
    }

    
    private func unverifyUser() {
        print("🚫 Unverified (Firebase later)")
        navigationController?.popViewController(animated: true)
    }

    private func suspendUser(duration: String) {
        print("⏳ Suspended for \(duration) (Firebase later)")
        navigationController?.popViewController(animated: true)
    }

    private func banUser() {
        print("⛔ Banned (Firebase later)")
        navigationController?.popViewController(animated: true)
    }


   }
