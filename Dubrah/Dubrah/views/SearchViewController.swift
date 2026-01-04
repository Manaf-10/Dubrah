//
//  SearchViewController.swift
//  Dubrah
//

import UIKit

final class SearchViewController: UIViewController,
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

    var allServices: [Service] = []
    var categories: [Category] = []
    var filteredServices: [Service] = []

    var isPriceAscending = true
    var isRatingAscending = false
    var isTitleAscending = true
    var selectedCategoryIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = ""
        navigationItem.backButtonTitle = ""
        navigationItem.backButtonDisplayMode = .minimal


        // Table
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120

        // Search + Collection
        searchBar.delegate = self
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self

        // Horizontal categories layout
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }

        // Dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false   // ✅ FIX 1 — put it HERE
        view.addGestureRecognizer(tapGesture)


        // Initial UI state
        noResultsLabel.isHidden = true
        filteredServices = []

        // Load services
        Task {
            do {
                try await loadData()
                await MainActor.run {
                    self.filteredServices = self.allServices
                    self.noResultsLabel.isHidden = !self.filteredServices.isEmpty
                    self.tableView.reloadData()
                }
            } catch {
                print("Failed to fetch services:", error.localizedDescription)
                await MainActor.run {
                    self.filteredServices = []
                    self.noResultsLabel.isHidden = false
                    self.tableView.reloadData()
                }
            }
        }

        // Load categories
        Task {
            do {
                let fetched = try await CategoriesController().getAllCategories()
                await MainActor.run {
                    self.categories = fetched
                    self.categoryCollectionView.reloadData()
                }
            } catch {
                print("Failed to fetch categories:", error.localizedDescription)
            }
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredServices.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ServiceCell",
            for: indexPath
        ) as? ServiceTableViewCell else {
            return UITableViewCell()
        }

        let service = filteredServices[indexPath.row]
        cell.configure(with: service)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selected = filteredServices[indexPath.row]
        print("Tapped row:", indexPath.row)

        let detailsVC = storyboard?.instantiateViewController(
            withIdentifier: "ServiceDetailsViewController"
        ) as! ServiceDetailsViewController

        detailsVC.serviceId = selected.id

        navigationController?.pushViewController(detailsVC, animated: true)
    }


    // MARK: - SearchBar

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilters(searchText: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }

    // MARK: - CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CategoryCell",
            for: indexPath
        ) as! CategoryCell

        let category = categories[indexPath.item]
        cell.categoryTitleLabel.text = category.title

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
        // Toggle selection
        if selectedCategoryIndex == indexPath {
            selectedCategoryIndex = nil
        } else {
            selectedCategoryIndex = indexPath
        }

        collectionView.reloadData()
        applyFilters(searchText: searchBar.text ?? "")
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let title = categories[indexPath.item].title
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let width = title.size(withAttributes: [.font: font]).width + 24
        return CGSize(width: width, height: 32)
    }

    // MARK: - Filtering (category + search together)

    private func applyFilters(searchText: String) {
        var result = allServices

        // Category filter
        if let selected = selectedCategoryIndex, selected.item < categories.count {
            let catTitle = categories[selected.item].title
            result = result.filter { $0.category == catTitle }
        }

        // Text filter
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let lower = trimmed.lowercased()
            result = result.filter { $0.title.lowercased().contains(lower) }
        }

        filteredServices = result
        noResultsLabel.isHidden = !filteredServices.isEmpty
        tableView.reloadData()
    }

    @IBAction func filterTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Sort Services",
            message: "Choose an option",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "Price (Low → High)", style: .default) { _ in
            self.filteredServices.sort { $0.price < $1.price }
            self.tableView.reloadData()
        })

        alert.addAction(UIAlertAction(title: "Price (High → Low)", style: .default) { _ in
            self.filteredServices.sort { $0.price > $1.price }
            self.tableView.reloadData()
        })

        // Sorting by Rating (High → Low)
        alert.addAction(UIAlertAction(title: "Rating (High → Low)", style: .default) { _ in
            self.filteredServices.sort { (a: Service, b: Service) in
                return a.averageRating > b.averageRating
            }
            self.tableView.reloadData()
        })

        // Sorting by Rating (Low → High)
        alert.addAction(UIAlertAction(title: "Rating (Low → High)", style: .default) { _ in
            self.filteredServices.sort { (a: Service, b: Service) in
                return a.averageRating < b.averageRating
            }
            self.tableView.reloadData()
        })

        alert.addAction(UIAlertAction(title: "Title (A → Z)", style: .default) { _ in
            self.filteredServices.sort {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
            self.tableView.reloadData()
        })

        alert.addAction(UIAlertAction(title: "Title (Z → A)", style: .default) { _ in
            self.filteredServices.sort {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending
            }
            self.tableView.reloadData()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }


    // MARK: - Data

    private func loadData() async throws {
        allServices = try await ServiceController.shared.getAllServices()
    }
}

