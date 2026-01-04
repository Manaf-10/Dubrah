//
//  ResultViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

enum ResultType {
    case success
    case error
    
    var title: String {
        switch self {
        case .success: return "Approved!"
        case .error: return "Error!"
        }
    }
    
    var titleColor: UIColor {
        switch self {
        case .success: return UIColor(red: 0.0, green: 0.48, blue: 0.98, alpha: 1.0) // Blue
        case .error: return UIColor(red: 0.93, green: 0.26, blue: 0.21, alpha: 1.0) // Red
        }
    }
}

final class ResultViewController: UIViewController {
    
    private let resultType: ResultType
    private let message: String
    private let onDismiss: (() -> Void)?
    
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    init(type: ResultType, message: String, onDismiss: (() -> Void)? = nil) {
        self.resultType = type
        self.message = message
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init(type:message:onDismiss:)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0) // Light gray background
        
        // Title Label (Approved! / Error!)
        titleLabel.text = resultType.title
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.textColor = resultType.titleColor
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Message Label
        messageLabel.text = message
        messageLabel.font = .systemFont(ofSize: 16, weight: .regular)
        messageLabel.textColor = .black
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)
        
        // Action Button
        actionButton.setTitle("Back to dashboard", for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        actionButton.backgroundColor = UIColor(red: 0.16, green: 0.42, blue: 0.96, alpha: 1.0) // Blue button
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.layer.cornerRadius = 18 // Rounded button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        view.addSubview(actionButton)
        
        // Layout
        NSLayoutConstraint.activate([
            // Title - centered vertically, slightly above center
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Message - below title
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Button - bottom
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            actionButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc private func dismissTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}
