//
//  ReportsViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 01/01/2026.
//

import UIKit

class AdminReportsViewController: AdminBaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var reports: [Report] = Report.allReports
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationTitle("Reports")
        setupNavigationAppearance()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)

        showTabBar()

       }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            // Ensure tab bar is visible
            showTabBar()
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

           // 🔑 Handle button tap
           cell.onViewTapped = { [weak self] in
               guard let self else { return }
               self.openReportDetails(report)
           }

           return cell
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8 // spacing below each cell
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
