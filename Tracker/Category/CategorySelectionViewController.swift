import UIKit

// MARK: - CategorySelectionViewControllerDelegate

protocol CategorySelectionViewControllerDelegate: AnyObject {
    func didSelectCategory(_ categoryTitle: String)
}

// MARK: - CategorySelectionViewController

final class CategorySelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    var initialSelectedCategory: String?
    weak var delegate: CategorySelectionViewControllerDelegate?
    private var tableViewHeightConstraint: NSLayoutConstraint?
    private lazy var viewModel = CategoryViewModel(selectedCategoryTitle: initialSelectedCategory)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .backgroundtracker
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .graytracker
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tintColor = .bluetracker
        tableView.layoutMargins = .zero
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blacktracker
        button.setTitle("add_category_button".localized, for: .normal)
        button.setTitleColor(.whitetracker, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "error_image")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "empty_categories_placeholder".localized
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .blacktracker
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        bindViewModel()
    }
    
    // MARK: - Private Methods
    
    private func setupScreen() {
        view.backgroundColor = .whitetracker
        title = "category_title".localized
        
        navigationItem.hidesBackButton = true
        
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        self.tableViewHeightConstraint = heightConstraint
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            heightConstraint,
            tableView.bottomAnchor.constraint(lessThanOrEqualTo: addCategoryButton.topAnchor, constant: -24),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func reloadPlaceholderVisibility() {
        let count = viewModel.numberOfCategories()
        let hasCategories = count > 0
        
        tableView.isHidden = !hasCategories
        placeholderImageView.isHidden = hasCategories
        placeholderLabel.isHidden = hasCategories
        
        let rowHeight: CGFloat = 75
        let maxAvailableHeight = view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 140
        let targetHeight = CGFloat(count) * rowHeight
        
        if maxAvailableHeight > 0 {
            tableViewHeightConstraint?.constant = min(targetHeight, maxAvailableHeight)
            tableView.isScrollEnabled = targetHeight > maxAvailableHeight
        } else {
            tableViewHeightConstraint?.constant = targetHeight
        }
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] in
            self?.tableView.reloadData()
            self?.reloadPlaceholderVisibility()
        }
        viewModel.onCategorySelected = { [weak self] selectedTitle in
            self?.delegate?.didSelectCategory(selectedTitle)
            self?.navigationController?.popViewController(animated: true)
        }
        reloadPlaceholderVisibility()
    }
    
    @objc private func didTapAddCategoryButton() {
        let newCategoryVC = CategoryViewController()
        newCategoryVC.delegate = self
        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CategorySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        let isLastRow = indexPath.row == viewModel.numberOfCategories() - 1
        cell.separatorInset = isLastRow
        ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let title = viewModel.categoryTitle(at: indexPath)
        let isSelected = viewModel.isCategorySelected(at: indexPath)
        
        cell.configure(with: title, isSelected: isSelected)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - CategoryViewControllerDelegate

extension CategorySelectionViewController: CategoryViewControllerDelegate {
    func didCreateCategory(with title: String) {
        viewModel.addCategory(title: title)
    }
}
