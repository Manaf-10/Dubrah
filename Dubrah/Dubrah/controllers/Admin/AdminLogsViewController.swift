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

    

    @IBOutlet weak var tableView: UITableView!

    private let logsService = AdminLogsService()
       private var logs: [Log] = []
       private var isLoading = false

       override func viewDidLoad() {
           super.viewDidLoad()

           navigationController?.interactivePopGestureRecognizer?.delegate = self
           navigationController?.interactivePopGestureRecognizer?.isEnabled = true

           setNavigationTitleWithBtn(
               title: "Recent Activity",
               imageName: "Back-Btn",
               target: self,
               action: #selector(backToHome)
           )

           tableView.delegate = self
           tableView.dataSource = self
           
           loadLogs()
       }
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           // Reload logs when returning to page
           if !isLoading {
               loadLogs()
           }
       }
       
       private func loadLogs() {
           guard !isLoading else { return }
           isLoading = true
           
           print("📥 Fetching all activity logs...")
           
           logsService.fetchAllLogs { [weak self] logs in
               self?.isLoading = false
               print("✅ Loaded \(logs.count) total logs")
               self?.logs = logs
               self?.tableView.reloadData()
           }
       }

       // MARK: - TableView DataSource

       func numberOfSections(in tableView: UITableView) -> Int {
           logs.count
       }

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           1
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "LogsPageCell") as! LogsTableViewCell
           let log = logs[indexPath.section]
           
           cell.setupCell(
               photo: log.icon,
               description: log.description,
               username: log.username,
               timestamp: log.timestamp
           )
           
           return cell
       }

       func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           8
       }

       func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
           UIView()
       }

       @objc func backToHome() {
           navigationController?.popViewController(animated: true)
       }
   }
