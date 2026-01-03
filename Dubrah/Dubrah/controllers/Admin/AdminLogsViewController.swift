//
//  LogsViewController 2.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 03/01/2026.
//


import UIKit

class AdminLogsViewController: AdminBaseViewController,
                          UIGestureRecognizerDelegate,
                          UITableViewDelegate,
                          UITableViewDataSource {

    var arrLogs: [Log] = Log.allLogs

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Enable swipe-back
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true

        // Custom back + title
        setNavigationTitleWithBtn(
            title: "Recent Activity",
            imageName: "Back-Btn",
            target: self,
            action: #selector(backToHome)
        )

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setTabBarHidden(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        setTabBarHidden(false)
    }


    

    // MARK: - TableView DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        arrLogs.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogsPageCell") as! LogsTableViewCell
        let data = arrLogs[indexPath.section]
        cell.setupCell(
            photo: data.icon,
            description: data.description,
            username: data.username,
            timestamp: data.time
        )
        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        8
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }

    // MARK: - Navigation

    @objc func backToHome() {
        navigationController?.popViewController(animated: true)
    }
}
