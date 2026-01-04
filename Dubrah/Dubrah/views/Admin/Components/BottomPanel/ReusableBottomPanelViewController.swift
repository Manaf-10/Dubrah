//
//  ReusableBottomPanelViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//

import UIKit

class ReusableBottomPanelViewController: UIViewController {

    @IBOutlet private weak var dimView: UIView!
        @IBOutlet private weak var cardView: UIView!
        @IBOutlet private weak var buttonsStackView: UIStackView!
    private let config: BottomPanelConfig

    init(config: BottomPanelConfig) {
        self.config = config
        super.init(nibName: "ReusableBottomPanelViewController", bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(config:) instead")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        buildButtons()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)

        cardView.layer.cornerRadius = 24
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardView.clipsToBounds = true

        // Tap outside to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        dimView.addGestureRecognizer(tap)
    }

    private func buildButtons() {
        // clear old buttons
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        config.actions.forEach { action in
            let btn = makeButton(action)
            buttonsStackView.addArrangedSubview(btn)
        }
    }

    private func makeButton(_ action: BottomPanelAction) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(action.title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.layer.cornerRadius = 14

        // fixed height for each button
        btn.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let primaryBlue = UIColor(named: "PrimaryBlue") ?? .systemBlue

        switch action.style {
        case .primary:
            btn.backgroundColor = primaryBlue
            btn.setTitleColor(.white, for: .normal)

        case .outline:
            btn.backgroundColor = .clear
            btn.layer.borderWidth = 1.5
            btn.layer.borderColor = primaryBlue.cgColor
            btn.setTitleColor(primaryBlue, for: .normal)

        case .destructive:
            btn.backgroundColor = .systemRed
            btn.setTitleColor(.white, for: .normal)
        }

        btn.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true) {
                action.handler()
            }
        }, for: .touchUpInside)

        return btn
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
}
