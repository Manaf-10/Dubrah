//
//  TermsAndCondtionViewController.swift
//  Dubrah
//
//  Created by user287722 on 1/3/26.
//

import UIKit

class TermsAndCondtionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleLbl = UILabel()
        titleLbl.text = "Terms & Conditions"
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

Welcome to Dubrah App. By creating an account or using our platform, you agree to these Terms and Conditions. Please read them carefully before proceeding.

1. General Overview
This app connects users with service providers for various creative and professional needs. By using the app, you agree to comply with these terms and any applicable laws and regulations.

2. Account Regestration
- You must provide accurate and complete information during registration.
- You are responsible for maintaining the confidentiality of your account credentials.
- The app team reserves the right to suspend or delete accounts that violate the rules or misuse the platform. 

3. Use of Services
- Users can browse, book, and rate services from registered providers.
- Service providers are responsible for the accuracy and quality of the services they list.
- All communication and transactions must be conducted through the app.

4. Payment   
- Payments must be completed securely through the supported methods within the app.
- The app does not store or share your financial information.

5. Reviews and Ratings
- Users can leave honest feedback after using a service.
- Offensive, false, or spam reviews are prohibited and may lead to account action.

6. Content Ownership
- Users retain ownership of content they upload (such as profile images or portfolio samples).

7. Privacy and Data
- The app collects minimal personal information for identification and communication purposes.
- We do not share personal data with third parties without consent.
- Refer to our Privacy Policy for full details.

8. Updates to Terms
These terms may be updated from time to time. Continued use of the app after changes means you accept the updated version.
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
