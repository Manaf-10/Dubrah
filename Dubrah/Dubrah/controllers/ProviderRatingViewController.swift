//
//  ProviderRatingViewController.swift
//  Dubrah
//
//  Created by Ali on 30/12/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProviderRatingViewController: UIViewController, UITextViewDelegate {
    
    var order: Order!
    var serviceReview: Review!
    var userId = Auth.auth().currentUser?.uid
    
    private var selectedRating = 0
    private let db = Firestore.firestore()
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var providerImageView: UIImageView!
    @IBOutlet weak var starsContainer: UIStackView!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var blueHeaderView: UIStackView!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var submitReview: UIButton!
    
    // MARK: - Lifecycle
      override func viewDidLoad() {
          super.viewDidLoad()

          navigationItem.hidesBackButton = true
          setupUI()
          setupStars()
          setupTextView()
          setupKeyboardHandling()
          fetchProviderImage()
      }

      deinit {
          NotificationCenter.default.removeObserver(self)
      }

      // MARK: - UI Setup
      private func setupUI() {
          blueHeaderView.layer.cornerRadius = 15
          makeCircular(providerImageView)

          reviewTextView.layer.cornerRadius = 12
          reviewTextView.layer.borderWidth = 1
          reviewTextView.layer.borderColor = UIColor.systemGray4.cgColor
      }

      private func setupStars() {
          for (index, view) in starsContainer.arrangedSubviews.enumerated() {
              if let button = view as? UIButton {
                  button.tag = index + 1
                  button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
              }
          }
      }

      private func setupTextView() {
          reviewTextView.delegate = self
          reviewTextView.setPlaceholder("Write here... (optional)")
          reviewTextView.returnKeyType = .done
      }

      // MARK: - Stars Logic
      @objc private func starTapped(_ sender: UIButton) {
          selectedRating = sender.tag
          updateStars()
          updateMoodText()
      }

      private func updateStars() {
          for (index, view) in starsContainer.arrangedSubviews.enumerated() {
              if let button = view as? UIButton {
                  let filled = index < selectedRating
                  button.setImage(
                      UIImage(named: filled ? "Filled_Union" : "Union"),
                      for: .normal
                  )
              }
          }
      }

      private func updateMoodText() {
          switch selectedRating {
          case 1: moodLabel.text = "Very Bad 😢"
          case 2: moodLabel.text = "Bad 😕"
          case 3: moodLabel.text = "Okay 🙂"
          case 4: moodLabel.text = "Good 😄"
          case 5: moodLabel.text = "Excellent 🤩"
          default: moodLabel.text = ""
          }
      }
        
//MARK: Actions
    @IBAction func submitReviewTapped(_ sender: UIButton) {
      
        guard selectedRating > 0 else {
            showRatingAlert()
            return
        }

        // Provider feedback text
        let providerFeedback =
            reviewTextView.textColor == .lightGray ? "" : (reviewTextView.text ?? "")

        // Build PROVIDER review
        let providerReviewData: [String: Any] = [
            "content": providerFeedback,
            "rate": selectedRating,
            "senderID": userId!,
            "createdAt": Timestamp(date: Date())
        ]

        // Build SERVICE review (already rated in previous screen)
        let serviceReviewData: [String: Any] = [
            "content": serviceReview.content,
            "rate": serviceReview.rate,
            "senderID": userId!,
            "createdAt": Timestamp(date: Date())
        ]

        Task {
            do {
                
                try await ServiceController.shared.addReview(
                    serviceId: order.serviceID,
                    review: serviceReviewData
                )

                
                try await ServiceController.shared.addProviderReview(
                    userId: order.providerID,
                    review: providerReviewData
                )

                
                try await db.collection("orders")
                    .document(order.id)
                    .updateData([
                        "serviceRating": serviceReview.rate,
                        "serviceFeedback": serviceReview.content,
                        "providerRating": selectedRating,
                        "providerFeedback": providerFeedback,
                        "status": "completed"
                    ])

                self.navigateToSuccess()

            } catch {
                print("Review submission failed:", error.localizedDescription)
            }
        }
     }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        let alert = UIAlertController(
                 title: "Exit Review",
                 message: "Are you sure you want to exit? Your review will not be saved.",
                 preferredStyle: .alert
             )

             alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
             alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
                 guard let nav = self.navigationController else { return }

                 for vc in nav.viewControllers {
                     if vc is OrderHistoryViewController {
                         nav.popToViewController(vc, animated: true)
                         return
                     }
                 }
                 nav.popViewController(animated: true)
             })

             present(alert, animated: true)
    }

        private func fetchProviderImage() {
            Firestore.firestore()
                .collection("user")
                .document(order.providerID)
                .getDocument { snapshot, error in

                    if let error = error {
                        print("Failed to fetch provider image:", error.localizedDescription)
                        self.providerImageView.image = UIImage(systemName: "person.crop.circle")
                        return
                    }

                    guard
                        let data = snapshot?.data(),
                        let imageUrl = data["profileImageUrl"] as? String,
                        let url = URL(string: imageUrl)
                    else {
                        self.providerImageView.image = UIImage(systemName: "person.crop.circle")
                        return
                    }

                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        guard let data else { return }
                        DispatchQueue.main.async {
                            self.providerImageView.image = UIImage(data: data)
                        }
                    }.resume()
                }
        }


    //MARK: Alerts
    func showRatingAlert() {
        let alert = UIAlertController(
            title: "Rating Required",
            message: "Please rate the provider before submitting.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    /*
    // MARK: - Navigation*/

    //MARK: Keyboard Handling
    private func setupKeyboardHandling() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ notification: Foundation.Notification) {
        guard
            let userInfo = notification.userInfo,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        view.frame.origin.y = -frame.height / 3
    }
    
    @objc private func keyboardWillHide(_ notification: Foundation.Notification) {
        view.frame.origin.y = 0
    }

    
    private func navigateToSuccess() {
        performSegue(withIdentifier: "toReviewSuccess", sender: nil)
    }
    
}


