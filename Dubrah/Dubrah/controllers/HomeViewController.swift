//
//  HomeViewController.swift
//  Dubrah
//
//  Created by BP-19-114-03 on 15/12/2025.
//
import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    @IBOutlet weak var welcomingLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            do {
                try await NotificationController.shared.newNotification(
                    receiverId: Auth.auth().currentUser?.uid ?? "",
                    senderId: reportSystemID,
                    type: .report
                )
                print("Success!")
            } catch {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }

        

       
        Task {
            do {
                try await AuthManager.shared.signIn(email: "test@gmail.com", password: "123456")
                if let user = AuthManager.shared.currentUser {
                    let attributedText = NSMutableAttributedString()
                    let line1 = NSAttributedString(
                        string: "Welcome,\n",
                        attributes: [
                            .font: UIFont.systemFont(ofSize: 12),
                            .foregroundColor: UIColor(hex:"#353E5C")
                        ]
                    )
                    
                    let line2 = NSAttributedString(
                        string: user.fullName + " ",
                        attributes: [
                            .font: UIFont.boldSystemFont(ofSize: 18),
                            .foregroundColor: UIColor(hex:"#353E5C")
                        ]
                    )
                    let attachment = NSTextAttachment()
                    attachment.image = UIImage(named: "verified")
                                attachment.bounds = CGRect(x: 0, y: -1, width: 14, height: 14)
                                let imageString = NSAttributedString(attachment: attachment)
                    
                    attributedText.append(line1)
                    attributedText.append(line2)
                    attributedText.append(imageString)
                    
                    user.isVerified ? attributedText.append(imageString) : ()
                    await MainActor.run {
                        self.welcomingLabel.attributedText = attributedText
                        Task{
                            if let image = await ImageDownloader.fetchImage(from: user.profilePicture) {
                                userImage.image = image
                                userImage.layer.cornerRadius = 35                            }
                        }
                    }
                }
                print("✅ Login Successful!")
            } catch {
                print("❌ Login Failed: \(error.localizedDescription)")
            }
        }
    }
}

