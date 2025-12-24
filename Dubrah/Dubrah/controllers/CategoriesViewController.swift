//
//  CategoriesViewController.swift
//  Dubrah
//
//  Created by BP-36-201-21 on 18/12/2025.
//

import UIKit
class CategoriesViewController: BaseViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,CategoryCellDelegate{

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIButton!
  
    private let refreshControl = UIRefreshControl() // pull to refresh
    
    var categories: [Category] = []
    var filteredCategories: [Category] = []
    var isSearching = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
        }

       setupStyle()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        Task{
            await loadData()
        }
        
    }
    
    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredCategories.count : categories.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CategoryCell",
            for: indexPath
        ) as! CategoryCell

        let item = isSearching
            ? filteredCategories[indexPath.item]
            : categories[indexPath.item]

        cell.iconLabel.text = item.title
        cell.delegate = self
        cell.categoryID = item.id
        return cell
    }

    // MARK: - CollectionView Layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let columns: CGFloat = 2
        let spacing: CGFloat = 12
        let inset: CGFloat = 16

        let totalSpacing = (columns - 1) * spacing + inset * 2
        let width = (collectionView.bounds.width - totalSpacing) / columns

        return CGSize(width: width, height: 140)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    

    // MARK: - SearchBar Logic (MATCHES MessagesViewController)
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            isSearching = false
            filteredCategories.removeAll()
        } else {
            isSearching = true
            filteredCategories = categories.filter {
                $0.title.lowercased().contains(text.lowercased())
            }
        }

        collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Updated Delete Logic
    func didTapDelete(on cell: CategoryCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let alert = UIAlertController(title: "Delete Category", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let item = self.isSearching ? self.filteredCategories[indexPath.item] : self.categories[indexPath.item]

            Task {
                do {

                    try await CategoriesController.shared.deleteCategory(id: item.id)
                    
                    await MainActor.run {
                        if self.isSearching {
                            self.filteredCategories.remove(at: indexPath.item)
                            self.categories.removeAll { $0.id == item.id }
                        } else {
                            self.categories.remove(at: indexPath.item)
                        }
                        self.collectionView.deleteItems(at: [indexPath])
                    }
                } catch {
                    print("Error deleting: \(error)")
                }
            }
        })
        present(alert, animated: true)
    }
    
    func didTapEdit(on cell: CategoryCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let item = isSearching
            ? filteredCategories[indexPath.item]
            : categories[indexPath.item]

        let alert = UIAlertController(
            title: "Edit Category",
            message: "Enter a new name",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.text = item.title
            textField.placeholder = "Category name"
            textField.autocapitalizationType = .words
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty else { return }

            // Duplicate check
            let nameExists = self.categories.contains {
                $0.title.lowercased() == newName.lowercased() &&
                $0.id != item.id
            }

            if nameExists {
                let errorAlert = UIAlertController(title: "Name Already Exists", message: "Choose a different name.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }

            Task {
                do {
                    
                    try await CategoriesController.shared.editCategory(id: item.id, newName: newName)
                    
                    await MainActor.run {
                        let updatedCategory = Category(id: item.id, title: newName)
                        
                        if self.isSearching {
                            self.filteredCategories[indexPath.item] = updatedCategory
                            if let index = self.categories.firstIndex(where: { $0.id == item.id }) {
                                self.categories[index] = updatedCategory
                            }
                        } else {
                            self.categories[indexPath.item] = updatedCategory
                        }
                        
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                } catch {
                    print("DEBUG: Error updating category: \(error)")
                }
            }
        })

        present(alert, animated: true)
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Add Category",
            message: "Enter a name for the new category",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Category name"
            textField.autocapitalizationType = .words
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !name.isEmpty else { return }

            // Duplicate check
            let nameExists = self.categories.contains { $0.title.lowercased() == name.lowercased() }

            if nameExists {
                let error = UIAlertController(title: "Name Already Exists", message: "Choose a different category name.", preferredStyle: .alert)
                error.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(error, animated: true)
                return
            }

            Task {
                do {

                    
                    try await CategoriesController.shared.addCategory(name: name)
                    
                    await MainActor.run {
                        self.isSearching = false
                        self.filteredCategories.removeAll()
                        self.searchBar.text = nil
                        
                        Task {
                            await self.loadData()
                        }
                    }
                } catch {
                    print("DEBUG: Failed to add category: \(error)")
                }
            }
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(addAction)

        present(alert, animated: true)
    }
    
    func loadData() async{	
        Task{
            do{
                categories = try await CategoriesController.shared.getAllCategories()
                await MainActor.run {
                    self.collectionView.reloadData()
                }
            } catch {
                print("DEBUG: Error loading categhories: \(error)")
            }
        }
    }
    
    @objc private func handleRefresh() {
        Task {
            await loadData()
            await MainActor.run {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    override func setupStyle() {
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.borderStyle = .none
        searchBar.backgroundColor = .white
        
        addButton.backgroundColor = .white
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = UIColor(hex: "#F6F8F9")
    }
}
