//
//  RequestsViewController.swift
//  Dubrah
//
//  Created by Abdulla Alansari on 23/12/2025.
//

import UIKit

class AdminRequestsViewController: AdminBaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    private let service = AdminRequestsService()
    private var requests: [UserRequest] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationTitle("Requests")
        setupNavigationAppearance()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadRequests()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTabBar()
        
        // Reload when coming back (in case requests were approved/rejected)
        loadRequests()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showTabBar()
    }
    
    private func loadRequests() {
        print("📥 Fetching verification requests...")
        
        service.fetchRequests { [weak self] requests in
            print("✅ Received \(requests.count) requests")
            self?.requests = requests
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - TableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestsTableViewCell
        
        let request = requests[indexPath.section]
        
        cell.setupCell(
            photoUrl: request.profilePictureUrl,
            name: request.name,
            role: request.role
        )
        
        // ✅ ADD THIS: Handle button tap from cell
        cell.onViewTapped = { [weak self] in
            self?.openRequestDetails(request)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    // ✅ ALSO support tapping the entire cell (not just the button)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let request = requests[indexPath.section]
        openRequestDetails(request)
    }
    
    private func openRequestDetails(_ request: UserRequest) {
        print("🔍 Opening details for: \(request.name)")
        
        let storyboard = UIStoryboard(name: "Requests", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "AdminUserRequestViewController") as? AdminUserRequestViewController else {
            print("❌ Failed to instantiate AdminUserRequestViewController")
            return
        }

        detailVC.request = request
        
        print("✅ Navigating to detail page with \(request.documents.count) documents")
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
