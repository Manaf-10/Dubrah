//
//  CustomTabBar.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 21/12/2025.
//

import UIKit

protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(index: Int)
}

class CustomTabBar: UIView {

    @IBOutlet var buttons: [UIButton]!
    weak var delegate: CustomTabBarDelegate?

    var selectedIndex: Int = 0 {
        didSet { updateSelection() }
    }

    private let titles = [
        "Home",
        "Users",
        "Requests",
        "Reports",
        "Profile"
    ]

    private let activeIcons = [
        "Home-Active",
        "Users-Active",
        "Requests-Active",
        "Reports-Active",
        "Profile-Active"
    ]

    private let inactiveIcons = [
        "Home-Inactive",
        "Users-Inactive",
        "Requests-Inactive",
        "Reports-Inactive",
        "Profile-Inactive"
    ]

    // MARK: - UI Update

    private func updateSelection() {
        guard let buttons, buttons.count == titles.count else {
            print("❌ CustomTabBar: buttons outlet collection not connected correctly")
            return
        }

        for (index, button) in buttons.enumerated() {
            let isActive = (index == selectedIndex)

            var config = UIButton.Configuration.plain()

            // Title
            config.title = titles[index]

            // Image
            let imageName = isActive ? activeIcons[index] : inactiveIcons[index]
            config.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)

            // Layout
            config.imagePlacement = .top
            config.imagePadding = 7   // ✅ EXACT GAP BETWEEN ICON & TITLE

            // Color
            config.baseForegroundColor = isActive ? .black : .lightGray

            // Font
            let font = isActive
                ? UIFont.boldSystemFont(ofSize: 12)
                : UIFont.systemFont(ofSize: 12)

            config.titleTextAttributesTransformer =
                UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = font
                    return outgoing
                }

            button.configuration = config
            button.tag = index
        }
    }

    // MARK: - Actions

    @IBAction func tabTapped(_ sender: UIButton) {
        delegate?.didSelectTab(index: sender.tag)
    }
}
