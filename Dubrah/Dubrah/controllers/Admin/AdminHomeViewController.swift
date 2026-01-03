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
        (parent as? UINavigationController)?
                .parent
                .flatMap { $0 as? AdminTabBarController }?
                .didSelectTab(index: 1)
    }
    
    @IBAction func didTapServices(_ sender: UIControl) {
        (parent as? UINavigationController)?
                .parent
                .flatMap { $0 as? AdminTabBarController }?
                .didSelectTab(index: 1)
    }
    
    
    @IBOutlet weak var tableView: UITableView!

    var recentLogs: [Log] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        recentLogs = Array(Log.allLogs.prefix(3))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
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
            timestamp: data.time
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
