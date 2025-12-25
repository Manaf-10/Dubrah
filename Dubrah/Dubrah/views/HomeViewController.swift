//
//  HomeViewController.swift
//  Dubrah
//
//  Created by BP-19-114-03 on 15/12/2025.
//
import UIKit
import FirebaseAuth

class HomeViewController: BaseViewController {
    @IBOutlet weak var welcomingLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task {
            do {
                // Log in
                try await AuthManager.shared.signIn(email: "test@gmail.com", password: "123456")
                
                if let user = AuthManager.shared.currentUser {
                    try await setUpStyle(user: user)
                    
                }
                print("✅ Login Successful!")
            } catch {
                print("❌ Error: \(error.localizedDescription)")
            }
        }
    }

    func setUpStyle(user: User) async throws {
        
        let attributedText = NSMutableAttributedString()
        
        let line1 = NSAttributedString(string: "Welcome,\n", attributes: [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor(hex:"#353E5C")
        ])
        
        let line2 = NSAttributedString(string: user.fullName + " ", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(hex:"#353E5C")
        ])
        
        attributedText.append(line1)
        attributedText.append(line2)
        
        if user.isVerified {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "verified")
            attachment.bounds = CGRect(x: 0, y: -1, width: 14, height: 14)
            attributedText.append(NSAttributedString(attachment: attachment))
        }

        let profileImg = await ImageDownloader.fetchImage(from: user.profilePicture)

        await MainActor.run {
            self.welcomingLabel.attributedText = attributedText
            if let image = profileImg {
                self.userImage.image = image
                self.userImage.layer.cornerRadius = self.userImage.frame.height / 2
                self.userImage.clipsToBounds = true
            }
        }
    }
}

