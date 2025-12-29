//
//  SearchViewController.swift
//  Dubrah
//
//  Created by BP-36-212-16N on 28/12/2025.
//

import UIKit

class SearchViewController: UIViewController,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            UISearchBarDelegate {

    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let allServices: [Service] = [
        Service(id: 1, name: "Haircut", price: 15.0, rating: 4.5),
        Service(id: 1, name: "Manicure", price: 20.0, rating: 4.8),
        Service(id: 1, name: "Massage", price: 50.0, rating: 4.9),
        Service(id: 1, name: "Facial", price: 40.0, rating: 4.7),
        Service(id: 1, name: "Hair Coloring", price: 60.0, rating: 4.6)
    ]

    var filteredServices: [Service] = []
    
    var isPriceAscending = true
    var isRatingAscending = false
    var isNameAscending = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredServices = allServices
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.keyboardDismissMode = .onDrag
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredServices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        let service = filteredServices[indexPath.row]
        cell.textLabel?.text = service.name
        cell.detailTextLabel?.text = "Price: $\(service.price) | Rating: \(service.rating)"
        
        return cell
    }

    func updateFilterButtonVisibility() {
        filterButton.isEnabled = !filteredServices.isEmpty
        filterButton.tintColor = filteredServices.isEmpty ? .clear : nil
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredServices = allServices
            noResultsLabel.isHidden = true
            
        } else {
            filteredServices = allServices.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
            noResultsLabel.isHidden = !filteredServices.isEmpty
        }

        tableView.reloadData()
        updateFilterButtonVisibility()
    }

    @IBAction func filterTapped(_ sender: UIButton) {
        showFilterOptions()
    }
    
    func showFilterOptions() {
        let priceTitle = isPriceAscending ? "Price (Low → High)" : "Price (High → Low)"
        let ratingTitle = isRatingAscending ? "Rating (Low → High)" : "Rating (High → Low)"
        let nameTitle = isNameAscending ? "Name (A-Z)" : "Name (Z-A)"
        let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: priceTitle, style: .default) { _ in
            self.sortByPrice()
        })

        alert.addAction(UIAlertAction(title: ratingTitle, style: .default) { _ in
            self.sortByRating()
        })

        alert.addAction(UIAlertAction(title: nameTitle, style: .default) { _ in
            self.sortByName()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    func sortByPrice() {
        filteredServices.sort {
            isPriceAscending ? $0.price < $1.price : $0.price > $1.price
        }
        isPriceAscending.toggle()
        tableView.reloadData()
    }

    func sortByRating() {
        filteredServices.sort {
            isRatingAscending ? $0.rating < $1.rating : $0.rating > $1.rating
        }
        isRatingAscending.toggle()
        tableView.reloadData()
    }

    func sortByName() {
        filteredServices.sort {
            isNameAscending
                ? $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending
        }
        isNameAscending.toggle()
        tableView.reloadData()
    }
}
