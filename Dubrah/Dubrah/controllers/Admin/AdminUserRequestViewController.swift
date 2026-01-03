//
//  UserRequestViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 01/01/2026.
//

import UIKit

class AdminUserRequestViewController: AdminBaseViewController, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var btnsView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var request: UserRequest?
        private var documents: [VerificationDocument] = []

    
    override func viewDidLoad() {
            super.viewDidLoad()

            setupNavigation()
            setupCollectionView()
            loadMockRequest()

            // Enable swipe-back safely
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

        private func loadMockRequest() {
            request = UserRequest(
                userId: "123",
                name: "Ahmed Ali",
                role: "Frontend Developer",
                documents: VerificationDocument.mockData
            )

            documents = request?.documents ?? []
            collectionView.reloadData()
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
            cell.setupCell(photo: UIImage(named: doc.imageName)!)

            return cell
        }

        // MARK: - CollectionView Layout
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

    // MARK: - Popups

    private func showApprovePopup() {
        let popup = ReusablePopupViewController(
            config: .confirm(
                title: "Approve Request",
                message: "Are you sure you want to approve this user?",
                confirmTitle: "Approve",
                cancelTitle: "Cancel",
                onConfirm: { [weak self] in
                    self?.approveRequest()
                },
                onCancel: nil
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
                },
                onCancel: nil
            )
        )

        present(popup, animated: true)
    }

    // MARK: - Business Logic (Firebase later)

    private func approveRequest() {
        print("✅ Request Approved")
        navigationController?.popViewController(animated: true)
    }

    private func rejectRequest() {
        print("❌ Request Rejected")
        navigationController?.popViewController(animated: true)
    }


        // MARK: - Tab Bar Handling
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            hideTabBar(animated: animated)
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            transitionCoordinator?.notifyWhenInteractionChanges { [weak self] context in
                if context.isCancelled {
                    self?.hideTabBar()
                }
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            transitionCoordinator?.animate(alongsideTransition: nil) { [weak self] context in
                if !context.isCancelled {
                    self?.showTabBar()
                }
            }
        }

        // MARK: - Layout
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()

            cardView.layer.cornerRadius = 24
            cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cardView.layer.masksToBounds = true

            btnsView.layer.cornerRadius = 24
            btnsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            btnsView.layer.masksToBounds = true
        }

        // MARK: - Navigation
        @objc private func backToHome() {
            navigationController?.popViewController(animated: true)
        }
    }
