//
//  HomeViewController.swift
//  Dubrah
//
//  Created by BP-19-114-03 on 15/12/2025.
//
import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var welcomingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let paragraphStyle = NSMutableParagraphStyle()
        let attributedText = NSMutableAttributedString()
        let attachment =  NSTextAttachment()
        let line1 = NSAttributedString(
            string: "Welcome,\n",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor(hex:"#353E5C"),
                .paragraphStyle: paragraphStyle
            ]
        )

        let line2 = NSAttributedString(
            // Dynamic name (change later when session is configured)
            string: "Manaf ",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor(hex:"#353E5C"),
                .paragraphStyle: paragraphStyle
            ]
        )
        
       
        

        //check from the sessi9on if the user is verified (later)
//        if(SessionDetails.isVerified){
            attachment.image = UIImage(named: "verified")
            attachment.bounds = CGRect(x: 0, y: -1, width: 14, height: 14)
            let imageString = NSAttributedString(attachment: attachment)
            attributedText.append(line1)
            attributedText.append(line2)
            attributedText.append(imageString)
//        }

        welcomingLabel.attributedText = attributedText
        welcomingLabel.numberOfLines = 0

    }

}
 
