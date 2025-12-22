//
//  AppDelegate.swift
//  Dubrah
//
//  Created by Abdulla Mohd Shams on 30/11/2025.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import Cloudinary

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let config = CLDConfiguration(cloudName: "dcothxbxk", secure: true)
    var cloudinary: CLDCloudinary!
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        cloudinary = CLDCloudinary(configuration: config)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                  sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
