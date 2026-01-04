//
//  ReusablePopupViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

final class ReusablePopupViewController: UIViewController {
    

   
    @IBOutlet private weak var dimView: UIView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var dynamicContentStack: UIStackView!
    @IBOutlet private weak var buttonsStack: UIStackView!
    @IBOutlet private weak var primaryButton: UIButton!
    @IBOutlet private weak var secondaryButton: UIButton!

    
    private let config: PopupConfig

    
    init(config: PopupConfig) {
        self.config = config
        super.init(nibName: "ReusablePopupViewController", bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(config:) to create ReusablePopupViewController")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyConfig()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true

        // Tap outside to dismiss (optional)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        dimView.addGestureRecognizer(tap)

        // Style buttons (you can match your PrimaryBlue)
        primaryButton.layer.cornerRadius = 12
        secondaryButton.layer.cornerRadius = 12
        secondaryButton.layer.borderWidth = 1.5
        secondaryButton.layer.borderColor = UIColor(named: "PrimaryBlue")?.cgColor
    }

    private func applyConfig() {
        titleLabel.text = config.title

        if let msg = config.message, !msg.isEmpty {
            messageLabel.text = msg
            messageLabel.isHidden = false
        } else {
            messageLabel.isHidden = true
        }

        // Clear dynamic content
        dynamicContentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        config.buildContent?(dynamicContentStack)

        // PRIMARY BUTTON (filled)
        primaryButton.setTitle(config.primaryTitle, for: .normal)
        primaryButton.backgroundColor = config.primaryColor
        primaryButton.setTitleColor(config.primaryTextColor, for: .normal)
        primaryButton.layer.cornerRadius = config.buttonCornerRadius

        // SECONDARY BUTTON (outline)
        secondaryButton.setTitle(config.secondaryTitle, for: .normal)
        secondaryButton.backgroundColor = .clear
        secondaryButton.layer.borderWidth = 1.5
        secondaryButton.layer.borderColor = config.secondaryColor.cgColor
        secondaryButton.setTitleColor(config.secondaryTextColor, for: .normal)
        secondaryButton.layer.cornerRadius = config.buttonCornerRadius
    }

    @IBAction private func primaryTapped(_ sender: UIButton) {
        print("🔵 PRIMARY BUTTON TAPPED")
        
        // ✅ Store the action before dismissing
        let action = config.primaryAction
        
        dismiss(animated: true) {
            // ✅ Add delay AFTER dismiss completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("🔵 Calling primaryAction")
                action?()
            }
        }
    }

    @IBAction private func secondaryTapped(_ sender: UIButton) {
        print("⚪️ SECONDARY BUTTON TAPPED")
        
        let action = config.secondaryAction
        
        dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                action?()
            }
        }
    }

    @objc private func dismissSelf() {
        secondaryTapped(secondaryButton)
    }
}
