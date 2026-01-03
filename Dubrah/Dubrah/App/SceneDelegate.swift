//
//  SceneDelegate.swift
//  Dubrah
//
//  Created by Abdulla Mohd Shams on 30/11/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        // show a temporary loading screen (optional)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()

        Task { @MainActor in
            let user = await AuthManager.shared.bootstrap()

            if user == nil {
                self.showLogin()
                return
            }

            // role check
            if user?.role.lowercased() == "admin" {
                self.showAdminHome()
            } else {
                self.showCustomerHome()
            }
        }
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    private func showLogin() {
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginNavigationController")
        window?.rootViewController = vc
    }

    private func showCustomerHome() {
        let storyboard = UIStoryboard(name: "User", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CustomerTabBarVC")
        window?.rootViewController = vc
    }

    private func showAdminHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AdminDashboardVC")
        window?.rootViewController = vc
    }


}

