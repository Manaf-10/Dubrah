//
//  ReportsViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 01/01/2026.
//

import UIKit

class AdminReportsViewController: AdminBaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    private let service = AdminReportsService()
     private var reports: [Report] = []
     
     override func viewDidLoad() {
         super.viewDidLoad()

         setupNavigationTitle("Reports")
         setupNavigationAppearance()
         
         // ✅ Add history button
         addHistoryButton()
         
         tableView.delegate = self
         tableView.dataSource = self
         
         loadReports()
     }
     
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         showTabBar()
         loadReports()
     }
     
     override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         showTabBar()
     }
     
     private func addHistoryButton() {
         let historyButton = UIBarButtonItem(
             image: UIImage(systemName: "clock.arrow.circlepath"),
             style: .plain,
             target: self,
             action: #selector(openHistory)
         )
         navigationItem.rightBarButtonItem = historyButton
     }
     
     @objc private func openHistory() {
         let historyVC = UIStoryboard(name: "Reports", bundle: nil)
             .instantiateViewController(withIdentifier: "ReportsHistoryViewController")
             as! ReportsHistoryViewController
         
         navigationController?.pushViewController(historyVC, animated: true)
     }
     
     private func loadReports() {
         print("📥 Fetching pending reports...")
         
         service.fetchPendingReports { [weak self] reports in
             print("✅ Loaded \(reports.count) pending reports")
             self?.reports = reports
             self?.tableView.reloadData()
         }
     }
     
     func numberOfSections(in tableView: UITableView) -> Int {
         return reports.count
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as! ReportsTableViewCell
         let report = reports[indexPath.section]
         
         cell.setupCell(report: report)
         cell.onViewTapped = { [weak self] in
             self?.openReportDetails(report)
         }
         
         return cell
     }
     
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         return 8
     }

     func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
         return UIView()
     }
     
     private func openReportDetails(_ report: Report) {
         let detailVC = UIStoryboard(name: "Reports", bundle: nil)
             .instantiateViewController(withIdentifier: "UserReportViewController")
             as! AdminUserReportViewController

         detailVC.report = report
         navigationController?.pushViewController(detailVC, animated: true)
     }
 }
