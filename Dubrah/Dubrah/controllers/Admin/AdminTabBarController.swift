//
//  AdminTabBarController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 25/12/2025.
//

import UIKit

class AdminTabBarController: UIViewController, CustomTabBarDelegate {
    
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabBarHostView: UIView!
    var selectedViewController: UINavigationController?
    private var customTabBar: CustomTabBar!
      private var navControllers: [UINavigationController] = []
      private var currentIndex = -1
      
      override func viewDidLoad() {
          super.viewDidLoad()
          setupTabBar()
          setupTabs()
          
          // Make sure tab bar is on top of content
          view.bringSubviewToFront(tabBarHostView)
          
          showTab(index: 0)
      }
    
    //  Update safe area when layout changes

    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            updateChildSafeAreas()
        }
    

      private func setupTabBar() {
          customTabBar = Bundle.main.loadNibNamed("CustomTabBar", owner: nil)?.first as? CustomTabBar
          guard let customTabBar else { return }

          tabBarHostView.addSubview(customTabBar)
          customTabBar.translatesAutoresizingMaskIntoConstraints = false

          NSLayoutConstraint.activate([
              customTabBar.leadingAnchor.constraint(equalTo: tabBarHostView.leadingAnchor),
              customTabBar.trailingAnchor.constraint(equalTo: tabBarHostView.trailingAnchor),
              customTabBar.topAnchor.constraint(equalTo: tabBarHostView.topAnchor),
              customTabBar.bottomAnchor.constraint(equalTo: tabBarHostView.bottomAnchor)
          ])

          customTabBar.delegate = self
      }

      private func setupTabs() {
          navControllers = [
              makeNav("AdminHome", "HomeViewController"),
              makeNav("Services", "ServicesViewController"), // will be edited later
              makeNav("Requests", "RequestsViewController"),
              makeNav("Reports", "ReportsViewController"),
              makeNav("Profile", "ProfileViewController")
          ]
      }

      private func makeNav(_ storyboard: String, _ id: String) -> UINavigationController {
          let vc = UIStoryboard(name: storyboard, bundle: nil)
              .instantiateViewController(withIdentifier: id)
          let nav = UINavigationController(rootViewController: vc)
          nav.navigationBar.prefersLargeTitles = false
          return nav
      }

      private func showTab(index: Int) {
          guard index != currentIndex else { return }

          if currentIndex >= 0 {
              let old = navControllers[currentIndex]
              old.willMove(toParent: nil)
              old.view.removeFromSuperview()
              old.removeFromParent()
          }

          let nav = navControllers[index]
          addChild(nav)
          nav.view.frame = contentView.bounds
          nav.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          contentView.addSubview(nav.view)
          nav.didMove(toParent: self)
          
//          Update safe area for the new nav controller
                  updateChildSafeAreas()

          customTabBar.selectedIndex = index
          currentIndex = index
      }

      func didSelectTab(index: Int) {
          showTab(index: index)
      }

      func setTabBarHidden(_ hidden: Bool, animated: Bool = false) {
          let changes = {
              self.tabBarHostView.alpha = hidden ? 0 : 1
              self.tabBarHostView.isHidden = hidden
              self.updateChildSafeAreas()
          }
          
          if animated {
              if !hidden {
                  // When showing, unhide first, then fade in
                  tabBarHostView.isHidden = false
              }
              UIView.animate(withDuration: 0.25, animations: {
                  self.tabBarHostView.alpha = hidden ? 0 : 1
              }, completion: { _ in
                  if hidden {
                      self.tabBarHostView.isHidden = true
                  }
                  self.updateChildSafeAreas()
              })
          } else {
              changes()
          }
      }
    
    //Automatically adjust safe area
    private func updateChildSafeAreas() {
          let tabBarHeight = tabBarHostView.isHidden ? 0 : tabBarHostView.frame.height
          
          for nav in navControllers {
              // Set bottom safe area inset to match tab bar height
              nav.additionalSafeAreaInsets.bottom = tabBarHeight
          }
      }
  
  }
