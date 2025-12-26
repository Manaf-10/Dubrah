//
//  PrivacyViewController.swift
//  Dubrah
//
//  Created by user282253 on 12/22/25.
//

import UIKit

class PrivacyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLbl = UILabel()
        titleLbl.text = "Privacy Policy"
        titleLbl.font = UIFont.boldSystemFont(ofSize: 24)
        titleLbl.textAlignment = .center
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLbl)

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
       
        let PrivacyTextView = UITextView()
        PrivacyTextView.isEditable = false
        PrivacyTextView.isSelectable = false
        PrivacyTextView.textAlignment = .left
        PrivacyTextView.font = UIFont.systemFont(ofSize: 16)
        PrivacyTextView.text = """
        1. Information We Collect
        - We collect only the information necessary to provide and improve our services:
        - Personal Information: Name, email address, date of birth, and profile photo.
        - Service Data: Bookings, reviews, and transaction details.
        - Device Data: App usage data, IP address, and device information for analytics and security.

        2. How We Use Your Information
        - Your information helps us to:
        - Create and manage your account.
        - Process bookings and payments.
        - Communicate important updates and notifications.
        - Personalize your experience within the app.
        - Improve app performance   

        3. Data Security
        - We use encryption and secure storage methods to protect your data.
        - Access to personal information is restricted to authorized personnel only.

        4. Sharing of Information   
        - We use encryption and secure storage methods to protect your data.
        - Access to personal information is restricted to authorized personnel only.

        5. Your Rights
        - Access and review your stored data.
        - Request correction or deletion of your information.

        6. Third-Party Services
        - Some services (like payments or login options) may link to third-party platforms.
        - We are not responsible for the privacy practices of these external sites or providers.

        7. Updates to This Policy
        We may update this Privacy Policy occasionally to reflect changes in our practices.
"""
        
        PrivacyTextView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(PrivacyTextView)
        
        
        NSLayoutConstraint.activate([
            PrivacyTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            PrivacyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            PrivacyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            PrivacyTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    



}
