//
//  TabBarController.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 18/12/2025.
//
import UIKit

class TabBarController : UITabBarController {
        
    override func viewDidLoad() {
            super.viewDidLoad()
            configureTabBar()
        }

        private func configureTabBar() {
            tabBar.backgroundColor = UIColor(hex: "#F6F8F9")
            tabBar.tintColor = .black                 // selected icon
            tabBar.unselectedItemTintColor = UIColor(hex: "#8A8B8C")
            tabBar.layer.cornerRadius = 16
            tabBar.layer.masksToBounds = true
            
        }
}
