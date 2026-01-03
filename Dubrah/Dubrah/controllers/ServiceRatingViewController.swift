//
//  ServiceRatingViewController.swift
//  Dubrah
//
//  Created by Ali on 30/12/2025.
//

import UIKit
import Foundation
import FirebaseFirestore
import FirebaseAuth

class ServiceRatingViewController: UIViewController, UITextViewDelegate {

    
    var order: Order!
      var serviceReview: Review?
      private var selectedRating = 0
    
    //MARK: IBOutlets
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var serviceImageView: UIImageView!
    @IBOutlet weak var starsContainer: UIStackView!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var blueHeaderView: UIStackView!
    @IBOutlet weak var continueButton: UIButton!
    
    
    // MARK: - Lifecycle
       override func viewDidLoad() {
           super.viewDidLoad()

           navigationItem.hidesBackButton = true
           setupUI()
           setupStars()
           setupTextView()
           setupKeyboardHandling()
           populateOrderData()
       }

       deinit {
           NotificationCenter.default.removeObserver(self)
       }

       // MARK: - Setup
       private func setupUI() {
           blueHeaderView.layer.cornerRadius = 15
           roundImage(serviceImageView, radius: 12)

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

       private func populateOrderData() {
           loadImage(from: order.serviceImageUrl)
       }

       // MARK: - Stars
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
    
    @IBAction func continueTapped(_ sender: Any) {
        guard selectedRating > 0 else {
                    showRatingAlert()
                    return
                }

                let feedback =
                    reviewTextView.textColor == .lightGray ? "" : reviewTextView.text ?? ""

                let reviewDict: [String: Any] = [
                    "content": feedback,
                    "rate": selectedRating,
                    "senderID": Auth.auth().currentUser?.uid ?? "",
                    "createdAt": Date()
                ]

                serviceReview = Review(dictionary: reviewDict)

                performSegue(withIdentifier: "toProviderRating", sender: nil)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Exit Review",
            message: "Are you sure you want to exit? Your review will not be saved.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let exitAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(exitAction)
        
        present(alert, animated: true)
    }
    
    //MARK: Alerts
    func showRatingAlert() {
        let alert = UIAlertController(
            title: "Rating Required",
            message: "Please rate the service before continuing.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProviderRating",
                   let vc = segue.destination as? ProviderRatingViewController {

                    vc.order = order
                    vc.serviceReview = serviceReview
                }
    }
    
    // MARK: - Keyboard Handling
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
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            serviceImageView.image = UIImage(systemName: "photo")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.serviceImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
//MARK: Textview Placeholder Handler

extension UITextView {

    func setPlaceholder(_ text: String) {
        self.text = text
        self.textColor = .lightGray
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidBeginEditingCustom),
            name: UITextView.textDidBeginEditingNotification,
            object: self)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidEndEditingCustom),
            name: UITextView.textDidEndEditingNotification,
            object: self)
    }

    @objc private func textDidBeginEditingCustom() {
        if self.textColor == .lightGray {
            self.text = ""
            self.textColor = .label
        }
    }

    @objc private func textDidEndEditingCustom() {
        if self.text.isEmpty {
            self.text = "Write here..."
            self.textColor = .lightGray
        }
    }
}

