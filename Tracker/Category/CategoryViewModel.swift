import UIKit

// MARK: - CategoryViewModel

final class CategoryViewModel {
    
    // MARK: - Properties
    var onCategoriesUpdated: (() -> Void)?
    var onCategorySelected: ((String) -> Void)? 
    
    private let categoryStore: TrackerCategoryStore
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet { onCategoriesUpdated?() }
    }
    
    private(set) var selectedCategoryTitle: String? {
        didSet { onCategoriesUpdated?() }
    }
    
    // MARK: - Initializers
    init(selectedCategoryTitle: String?, categoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.selectedCategoryTitle = selectedCategoryTitle
        self.categoryStore = categoryStore
        self.categoryStore.delegate = self
        fetchCategories()
    }
    
    // MARK: - Public Methods
    func fetchCategories() {
        self.categories = categoryStore.categories
    }
    
    func addCategory(title: String) {
        try? categoryStore.addCategory(title: title)
        fetchCategories()
    }
    
    func numberOfCategories() -> Int {
        return categories.count
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String {
        return categories[indexPath.row].title
    }
    
    func isCategorySelected(at indexPath: IndexPath) -> Bool {
        return categories[indexPath.row].title == selectedCategoryTitle
    }
    
    func selectCategory(at indexPath: IndexPath) {
        let title = categories[indexPath.row].title
        self.selectedCategoryTitle = title
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.onCategorySelected?(title)
        }
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeDidChangeCategories() {
        fetchCategories()
    }
}
