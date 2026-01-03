//
//  ServiceDetailsViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

class AdminServiceDetailsViewController: AdminBaseViewController, UIGestureRecognizerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var providerAvatarImageView: UIImageView!
    @IBOutlet weak var providerNameLabel: UILabel!

    @IBOutlet weak var takeActionButton: UIButton!

 
    // MARK: - Data
    var service: Service?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

//        guard let service else {
//            fatalError("❌ ServiceDetailsViewController opened without Service")
//        }
        
        // Enable swipe-back
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        providerAvatarImageView.layer.cornerRadius =
            providerAvatarImageView.frame.width / 2
    }

    // MARK: - UI
    private func configureUI() {
        serviceImageView.contentMode = .scaleAspectFill
        serviceImageView.clipsToBounds = true

        providerAvatarImageView.clipsToBounds = true

//        takeActionButton.layer.cornerRadius = 16
    }

    private func bindData() {
        guard let service else { return }

        serviceImageView.image = service.image
        titleLabel.text = service.title
        descriptionLabel.text = service.description

        providerNameLabel.text = service.provider
        providerAvatarImageView.image = service.avatar
    }

    // MARK: - Actions
    @IBAction func takeActionTapped(_ sender: UIButton) {
        showServiceActionsPanel()
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
        guard let service else { return }

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
                onSubmit: { title, description in
                    print("✏️ Update service:", title, description)
                    // Firebase later
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
                onConfirm: {
                    print("🗑 Delete service (Firebase later)")
                }
            )
        )

        present(popup, animated: true)
    }
    
    @objc private func backToHome() {
        navigationController?.popViewController(animated: true)
    }
}

