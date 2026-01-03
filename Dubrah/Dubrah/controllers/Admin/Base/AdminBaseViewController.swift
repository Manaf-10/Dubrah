//
//  BaseViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 01/01/2026.
//

import UIKit

class AdminBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationAppearance()
    }

    func setupNavigationTitle(_ text: String) {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }

    func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    func setNavigationTitleWithBtn(
        title: String,
        imageName: String,
        target: Any?,
        action: Selector
    ) {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: imageName)
        config.title = title
        config.imagePadding = 10
        config.baseForegroundColor = .label
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: -8,
            bottom: 0,
            trailing: 0
        )

        let font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([.font: font])
        )

        let button = UIButton(configuration: config)
        button.addTarget(target, action: action, for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
}

// MARK: - Custom Tab Bar Handling

extension AdminBaseViewController {

    func adminTabBarController() -> AdminTabBarController? {
        var parentVC = parent
        while parentVC != nil {
            if let admin = parentVC as? AdminTabBarController {
                return admin
            }
            parentVC = parentVC?.parent
        }
        return nil
    }

    func hideTabBar(animated: Bool = false) {
        adminTabBarController()?.setTabBarHidden(true, animated: animated)
    }

    func showTabBar(animated: Bool = false) {
        adminTabBarController()?.setTabBarHidden(false, animated: animated)
    }
}
