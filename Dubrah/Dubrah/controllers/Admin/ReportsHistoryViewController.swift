//
//  ReportsHistoryViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 04/01/2026.
//

import UIKit

class ReportsHistoryViewController: AdminBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
      private let service = AdminReportsService()
      private var reports: [Report] = []
      
      override func viewDidLoad() {
          super.viewDidLoad()
          
          // ✅ Add safety check
          guard tableView != nil else {
              print("❌ ERROR: tableView outlet not connected!")
              return
          }
          
          setupNavigationTitle("Reports History")
          setupNavigationAppearance()
          
          // ✅ Add back button
          setNavigationTitleWithBtn(
              title: "Reports History",
              imageName: "Back-Btn",
              target: self,
              action: #selector(backToHome)
          )
          
          // export button
          addExportButton()
          
          tableView.delegate = self
          tableView.dataSource = self
          
          loadHistory()
      }
      
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          hideTabBar(animated: true)
      }
      
      override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          showTabBar()
      }
      
      @objc private func backToHome() {
          navigationController?.popViewController(animated: true)
      }
      
      private func addExportButton() {
          let exportButton = UIBarButtonItem(
              image: UIImage(named: "Reports-History"),
              style: .plain,
              target: self,
              action: #selector(exportToCSV)
          )
          navigationItem.rightBarButtonItem = exportButton
      }
      
      private func loadHistory() {
          print("📥 Fetching report history...")
          
          service.fetchReportHistory { [weak self] reports in
              print("✅ Loaded \(reports.count) historical reports")
              self?.reports = reports
              self?.tableView.reloadData()
          }
      }
      
      @objc private func exportToCSV() {
          guard !reports.isEmpty else {
              showAlert(title: "No Data", message: "No reports to export")
              return
          }
          
          let csvString = generateCSV()
          shareCSV(csvString)
      }
      
      private func generateCSV() -> String {
          var csv = "Report ID,Date,Type,Status,Reporter,Reported User,Title,Description\n"
          
          for report in reports {
              let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
              let date = dateFormatter.string(from: report.createdAt)
              
              let row = [
                  report.reportId,
                  date,
                  report.reportType,
                  report.status,
                  report.reporterName ?? "Unknown",
                  report.reportedUserName ?? "Unknown",
                  report.title.replacingOccurrences(of: ",", with: ";"),
                  report.description.replacingOccurrences(of: ",", with: ";")
              ].joined(separator: ",")
              
              csv += row + "\n"
          }
          
          return csv
      }
      
      private func shareCSV(_ csvString: String) {
          let fileName = "reports_history_\(Date().timeIntervalSince1970).csv"
          let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
          
          do {
              try csvString.write(to: path, atomically: true, encoding: .utf8)
              
              let activityVC = UIActivityViewController(
                  activityItems: [path],
                  applicationActivities: nil
              )
              
              // For iPad
              if let popover = activityVC.popoverPresentationController {
                  popover.barButtonItem = navigationItem.rightBarButtonItem
              }
              
              present(activityVC, animated: true)
              
          } catch {
              print("Error creating CSV: \(error)")
              showAlert(title: "Error", message: "Failed to create CSV file")
          }
      }
      
      private func showAlert(title: String, message: String) {
          let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          present(alert, animated: true)
      }
      
      // MARK: - Table View
      
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return reports.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! ReportHistoryCell
          
          cell.setupCell(report: reports[indexPath.row])
          return cell
      }
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          tableView.deselectRow(at: indexPath, animated: true)
          
          // Navigate to detail page
          let report = reports[indexPath.row]
          let detailVC = UIStoryboard(name: "Reports", bundle: nil)
              .instantiateViewController(withIdentifier: "UserReportViewController")
              as! AdminUserReportViewController
          
          detailVC.report = report
          detailVC.isHistoryView = true
          navigationController?.pushViewController(detailVC, animated: true)
      }
  }
