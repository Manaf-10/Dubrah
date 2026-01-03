//
//  SearchViewController.swift
//  Dubrah
//

import UIKit

class SearchViewController: UIViewController,
                            UITableViewDelegate,
                            UITableViewDataSource,
                            UISearchBarDelegate,
                            UICollectionViewDelegate,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let allServices: [Service] = []

    var categories: [Category] = []
    var filteredServices: [Service] = []
    
    var isPriceAscending = true
    var isRatingAscending = false
    var isTitleAscending = true
    var selectedCategoryIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        searchBar.delegate = self
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        // Horizontal scrolling layout for categories
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Load categories
        Task {
            do {
                categories = try await CategoriesController().getAllCategories()
                categoryCollectionView.reloadData()
            } catch {
                print("Failed to fetch categories:", error.localizedDescription)
            }
        }
        
        filteredServices = allServices
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredServices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as? ServiceTableViewCell else {
            return UITableViewCell()
        }

        let service = filteredServices[indexPath.row]
        cell.configure(with: service)
        return cell
    }

    // MARK: - SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredServices = allServices
            noResultsLabel.isHidden = true
        } else {
            filteredServices = allServices.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            noResultsLabel.isHidden = !filteredServices.isEmpty
        }
        tableView.reloadData()
    }

    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = categories[indexPath.item]
        cell.categoryTitleLabel.text = category.title

        // Highlight selected
        if indexPath == selectedCategoryIndex {
            cell.contentView.backgroundColor = .systemBlue
            cell.categoryTitleLabel.textColor = .white
        } else {
            cell.contentView.backgroundColor = .systemGray6
            cell.categoryTitleLabel.textColor = .label
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCategoryIndex = indexPath
        let category = categories[indexPath.item]
        filterServices(by: category)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = categories[indexPath.item].title
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let width = title.size(withAttributes: [.font: font]).width + 24
        return CGSize(width: width, height: 32)
    }

    // MARK: - Filter
    func filterServices(by category: Category) {
        filteredServices = allServices.filter { $0.category == category.title }
        tableView.reloadData()
        noResultsLabel.isHidden = !filteredServices.isEmpty
    }
}
