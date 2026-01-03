//
//  ServiceDetailsViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit
import FirebaseFirestore

class AdminServiceDetailsViewController: AdminBaseViewController, UIGestureRecognizerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var providerAvatarImageView: UIImageView!
    @IBOutlet weak var providerNameLabel: UILabel!

    @IBOutlet weak var takeActionButton: UIButton!

 
    var service: Service?
     private let servicesService = AdminServicesService()

     override func viewDidLoad() {
         super.viewDidLoad()

         guard service != nil else {
             print("❌ No service provided")
             navigationController?.popViewController(animated: false)
             return
         }
         
         navigationController?.interactivePopGestureRecognizer?.delegate = self
         navigationController?.interactivePopGestureRecognizer?.isEnabled = true

         setNavigationTitleWithBtn(
             title: "View Details",
             imageName: "Back-Btn",
             target: self,
             action: #selector(backToHome)
         )

         configureUI()
         bindData()
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

     override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         providerAvatarImageView.layer.cornerRadius = providerAvatarImageView.frame.width / 2
     }

     private func configureUI() {
         serviceImageView.contentMode = .scaleAspectFill
         serviceImageView.clipsToBounds = true
         providerAvatarImageView.clipsToBounds = true
     }

     private func bindData() {
         guard let service = service else { return }

         titleLabel.text = service.title
         descriptionLabel.text = service.description
         providerNameLabel.text = service.providerName ?? "Unknown Provider"
         
         // Load images
         serviceImageView.loadFromUrl(service.image)
         
         if let avatarUrl = service.providerAvatar {
             providerAvatarImageView.loadFromUrl(avatarUrl)
         } else {
             providerAvatarImageView.image = UIImage(named: "Log-Profile")
         }
     }

    // MARK: - Actions
    @IBAction func takeActionTapped(_ sender: UIButton) {
        showServiceActionsPanel()
    }
    @objc private func backToHome() {
        navigationController?.popViewController(animated: true)
    }
}

extension AdminServiceDetailsViewController {

    func showServiceActionsPanel() {
        let panel = ReusableBottomPanelViewController(
            config: BottomPanelConfig(actions: [
                BottomPanelAction(
                    title: "Modify Post",
                    style: .outline
                ) { [weak self] in
                    self?.showModifyPopup()
                },
                BottomPanelAction(
                    title: "Delete Post",
                    style: .destructive
                ) { [weak self] in
                    self?.showDeletePopup()
                }
            ])
        )
        present(panel, animated: true)
    }

    private func showModifyPopup() {
        guard let service = service else { return }

        let popup = ReusablePopupViewController(
            config: PopupConfig.form(
                title: "Modify Post",
                fields: [
                    PopupTextField(
                        placeholder: "Service Title",
                        text: service.title
                    ),
                    PopupTextField(
                        placeholder: "Description",
                        text: service.description
                    )
                ],
                confirmTitle: "Save",
                cancelTitle: "Cancel",
                onSubmit: { [weak self] title, description in
                    self?.updateService(title: title, description: description)
                }
            )
        )
        present(popup, animated: true)
    }

    private func showDeletePopup() {
        let popup = ReusablePopupViewController(
            config: PopupConfig.confirm(
                title: "Delete Post",
                message: "This action cannot be undone.",
                confirmTitle: "Delete",
                cancelTitle: "Cancel",
                onConfirm: { [weak self] in
                    self?.deleteService()
                }
            )
        )
        present(popup, animated: true)
    }
    
    private func updateService(title: String, description: String) {
        guard let serviceId = service?.id else { return }
        
        print("✏️ Updating service: \(serviceId)")
        
        servicesService.updateService(serviceId: serviceId, title: title, description: description) { [weak self] success in
            if success {
                // Update local model
                self?.service?.title = title
                self?.service?.description = description
                self?.bindData()
                
                self?.showSuccessAlert(message: "Service updated successfully!")
            } else {
                self?.showErrorAlert(message: "Failed to update service")
            }
        }
    }
    
    private func deleteService() {
        guard let serviceId = service?.id else { return }
        
        print("🗑 Deleting service: \(serviceId)")
        
        servicesService.deleteService(serviceId: serviceId) { [weak self] success in
            if success {
                self?.showSuccessAlert(message: "Service deleted successfully!") {
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
                self?.showErrorAlert(message: "Failed to delete service")
            }
        }
    }
    
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
}
