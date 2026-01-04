//
//  HomeViewController.swift
//  Dubrah
//
//  Created by Abdulla Mohd Shams on 04/12/2025.
//

import UIKit

class AdminHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func didTapRequests(_ sender: UIControl) {
        (parent as? UINavigationController)?
                .parent
                .flatMap { $0 as? AdminTabBarController }?
                .didSelectTab(index: 2)
    }
    
    @IBAction func didTapReports(_ sender: UIControl) {
        (parent as? UINavigationController)?
                .parent
                .flatMap { $0 as? AdminTabBarController }?
                .didSelectTab(index: 3)
    }
    
    @IBAction func didTapUsers(_ sender: UIControl) {
        switchToTab(1, segment: 0)  // Browse tab, Users segment
    }

    @IBAction func didTapServices(_ sender: UIControl) {
        switchToTab(1, segment: 1)  // Browse tab, Services segment
    }

    private func switchToTab(_ index: Int, segment: Int = 0) {
        if let tabBarController = (parent as? UINavigationController)?.parent as? AdminTabBarController {
            tabBarController.didSelectTab(index: index)
            
            if segment > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let navController = tabBarController.selectedViewController as? UINavigationController,
                       let browseVC = navController.viewControllers.first as? AdminUsersViewController {
                        browseVC.segmentedControl.selectedSegmentIndex = segment
                        browseVC.segmentChanged()
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!

    private let logsService = AdminLogsService()  // ✅ Add this
       private var recentLogs: [Log] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        loadRecentLogs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        loadRecentLogs()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func loadRecentLogs() {
           logsService.fetchAllLogs { [weak self] logs in
               // Get only the 3 most recent logs
               self?.recentLogs = Array(logs.prefix(3))
               self?.tableView.reloadData()
           }
       }
    

    // MARK: - TableView DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return recentLogs.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeLogCell") as! LogsTableViewCell
        let data = recentLogs[indexPath.section]
        cell.setupCell(
            photo: data.icon,
            description: data.description,
            username: data.username,
            timestamp: data.timestamp
        )
        return cell
    }

    // MARK: - TableView Spacing (your existing layout)

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == recentLogs.count - 1 ? 0 : 8
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }
}
