//
//  BaseViewController.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 18/12/2025.
//
import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F6F8F9")
    }
    
    func setupStyle() {
        
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupNavigation(title: String) {
        let backButton = UIButton(type: .system)
        backButton.setTitle("← \(title)", for: .normal)
        backButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    
}

