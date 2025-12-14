//
//  NotificationPage.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 14/12/2025.
//
import UIKit

class NotificationPage : UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationController?.navigationBar.tintColor = .black
//        navigationController?.navigationBar.topItem?.backButtonTitle = "Notifications"
//        navigationController?.navigationBar.topItem?.backButtonTitle = "Notifications"
//
//
//    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIButton(type: .system)
        backButton.setTitle("← Notifications", for: .normal)
        backButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
}
