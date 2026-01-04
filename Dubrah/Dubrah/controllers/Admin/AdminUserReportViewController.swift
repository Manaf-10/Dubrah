//
//  UserReportViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 02/01/2026.
//

import UIKit
import FirebaseFirestore

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

    var report: Report!
    var isHistoryView: Bool = false
       
       private let db = Firestore.firestore()
       private let reportsService = AdminReportsService()
       private let servicesService = AdminServicesService()

       override func viewDidLoad() {
           super.viewDidLoad()
           
           guard report != nil else {
               print("❌ No report provided")
               navigationController?.popViewController(animated: false)
               return
           }
           
           configureUI()
           bindData()
           
           if isHistoryView {
                   hideActionButtons()
               }

           
           navigationController?.interactivePopGestureRecognizer?.delegate = self
           navigationController?.interactivePopGestureRecognizer?.isEnabled = true
           
           setNavigationTitleWithBtn(
               title: "View Details",
               imageName: "Back-Btn",
               target: self,
               action: #selector(backToHome)
           )
       }
    
    private func hideActionButtons() {
        btnsView.isHidden = true

    }
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           hideTabBar(animated: animated)
       }
       
       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           
           if let coordinator = transitionCoordinator {
               coordinator.notifyWhenInteractionChanges { [weak self] context in
                   if context.isCancelled {
                       self?.hideTabBar()
                   }
               }
           } else {
               hideTabBar()
           }
       }

       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           
           if let coordinator = transitionCoordinator {
               coordinator.animate(alongsideTransition: nil) { [weak self] context in
                   if !context.isCancelled {
                       self?.showTabBar()
                   }
               }
           } else {
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
           reportedAvatarImg.layer.cornerRadius = reportedAvatarImg.frame.width / 2
           
           cardView.layer.cornerRadius = 24
           cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
           cardView.layer.masksToBounds = true
           
           btnsView.layer.cornerRadius = 24
           btnsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
           btnsView.layer.masksToBounds = true
       }

       private func bindData() {
           usernameLabel.text = report.reporterName ?? "Unknown"
           emailLabel.text = report.reporterEmail ?? "No email"
           typeButton.setTitle(report.reportType.capitalized, for: .normal)
           titleLabel.text = report.title
           descriptionLabel.text = report.description
           reportedUsernameLabel.text = report.reportedUserName ?? "Unknown"
           
           // Load avatars
           if let avatarUrl = report.reporterAvatar {
               avatarImageView.loadFromUrl(avatarUrl)
           } else {
               avatarImageView.image = UIImage(named: "Log-Profile")
           }
           
           if let reportedAvatarUrl = report.reportedUserAvatar {
               reportedAvatarImg.loadFromUrl(reportedAvatarUrl)
           } else {
               reportedAvatarImg.image = UIImage(named: "Log-Profile")
           }
       }
       
       @IBAction func takeActionTapped(_ sender: UIButton) {
           showTakeActionPanel()
       }
       
       @IBAction func ignoreTapped(_ sender: UIButton) {
           showIgnorePopup()
       }
       
       @objc private func backToHome() {
           navigationController?.popViewController(animated: true)
       }
       
       private func showTakeActionPanel() {
           var actions: [BottomPanelAction] = [
               BottomPanelAction(title: "Unverify User", style: .outline) { [weak self] in
                   self?.showUnverifyPopup()
               },
               BottomPanelAction(title: "Suspend User", style: .outline) { [weak self] in
                   self?.showSuspendPopup()
               },
               BottomPanelAction(title: "Ban User", style: .destructive) { [weak self] in
                   self?.showBanPopup()
               }
           ]
           
           // ✅ Add "Delete Service" if report is about a service
           if report.reportType.lowercased() == "service" {
               actions.append(
                   BottomPanelAction(title: "Delete Service", style: .destructive) { [weak self] in
                       self?.showDeleteServicePopup()
                   }
               )
           }
           
           let panel = ReusableBottomPanelViewController(config: BottomPanelConfig(actions: actions))
           present(panel, animated: true)
       }

       // MARK: - Popups
       
       private func showIgnorePopup() {
           let popup = ReusablePopupViewController(
               config: .confirm(
                   title: "Ignore Report",
                   message: "Mark this report as ignored without taking action?",
                   confirmTitle: "Ignore",
                   cancelTitle: "Cancel",
                   onConfirm: { [weak self] in
                       self?.ignoreReport()
                   }
               )
           )
           present(popup, animated: true)
       }
       
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

       private func showSuspendPopup() {
           let popup = ReusablePopupViewController(
               config: .suspension(
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
       
       private func showDeleteServicePopup() {
           let popup = ReusablePopupViewController(
               config: .confirm(
                   title: "Delete Service",
                   message: "This will permanently delete the reported service. Continue?",
                   confirmTitle: "Delete",
                   cancelTitle: "Cancel",
                   onConfirm: { [weak self] in
                       self?.deleteService()
                   }
               )
           )
           present(popup, animated: true)
       }

       // MARK: - Firebase Actions
    
    private let logsService = AdminLogsService()

    private func unverifyUser() {
        guard let userId = report.reportedUserId else { return }
        
        db.collection("user").document(userId).updateData(["verified": false]) { [weak self] error in
            guard let self = self else { return }
            
            if error == nil {
                // ✅ Log admin action
                self.logsService.logAdminAction(
                    action: .adminUnverifiedUser,
                    targetUsername: self.report.reportedUserName
                )
                
                self.reportsService.updateReportStatus(reportId: self.report.id, status: "resolved") { _ in }
                
                self.showResultPage(type: .success, message: "User has been unverified successfully") {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.showResultPage(type: .error, message: "Failed to unverify user")
            }
        }
    }

    private func suspendUser(duration: String) {
        guard let userId = report.reportedUserId else { return }
        
        var days = 0
        switch duration {
        case "24 Hours": days = 1
        case "3 Days": days = 3
        case "7 Days": days = 7
        case "1 Month": days = 30
        case "Permanent": days = 36500
        default: days = 1
        }
        
        let suspendedUntil = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        
        db.collection("user")
            .document(userId)
            .updateData([
                "suspended": true,
                "suspendedUntil": Timestamp(date: suspendedUntil)
            ]) { [weak self] error in
                guard let self = self else { return }
                
                if error == nil {
                    // ✅ Log admin action
                    self.logsService.logAdminAction(
                        action: .adminSuspendedUser,
                        targetUsername: self.report.reportedUserName,
                        details: "Suspended for \(duration)"
                    )
                    
                    self.reportsService.updateReportStatus(reportId: self.report.id, status: "resolved") { _ in }
                    
                    self.showResultPage(type: .success, message: "User has been suspended for \(duration)") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.showResultPage(type: .error, message: "Failed to suspend user")
                }
            }
    }

    private func banUser() {
        guard let userId = report.reportedUserId else { return }
        
        db.collection("user")
            .document(userId)
            .updateData([
                "banned": true,
                "verified": false
            ]) { [weak self] error in
                guard let self = self else { return }
                
                if error == nil {
                    // ✅ Log admin action
                    self.logsService.logAdminAction(
                        action: .adminBannedUser,
                        targetUsername: self.report.reportedUserName
                    )
                    
                    self.reportsService.updateReportStatus(reportId: self.report.id, status: "resolved") { _ in }
                    
                    self.showResultPage(type: .success, message: "User has been banned permanently") {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.showResultPage(type: .error, message: "Failed to ban user")
                }
            }
    }

    private func deleteService() {
        guard let serviceId = report.serviceId else { return }
        
        servicesService.deleteService(serviceId: serviceId) { [weak self] success in
            guard let self = self else { return }
            
            if success {
                // ✅ Log admin action
                self.logsService.logAdminAction(
                    action: .adminDeletedService,
                    details: self.report.serviceName
                )
                
                self.reportsService.updateReportStatus(reportId: self.report.id, status: "resolved") { _ in }
                
                self.showResultPage(type: .success, message: "Service has been deleted successfully") {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.showResultPage(type: .error, message: "Failed to delete service")
            }
        }
    }

    private func ignoreReport() {
        reportsService.updateReportStatus(reportId: report.id, status: "ignored") { [weak self] success in
            guard let self = self else { return }
            
            if success {
                // ✅ Log admin action
                self.logsService.logAdminAction(
                    action: .adminIgnoredReport,
                    details: self.report.title
                )
                
                self.showResultPage(type: .success, message: "Report has been ignored") {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.showResultPage(type: .error, message: "Failed to update report status")
            }
        }
    }
       
       private func showResultPage(type: ResultType, message: String, onDismiss: (() -> Void)? = nil) {
           let resultVC = ResultViewController(type: type, message: message, onDismiss: onDismiss)
           present(resultVC, animated: true)
       }
   }
