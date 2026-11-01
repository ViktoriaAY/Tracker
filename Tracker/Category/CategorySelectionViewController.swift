import UIKit

protocol CategorySelectionViewControllerDelegate: AnyObject {
    func didSelectCategory(_ categoryTitle: String)
}

// MARK: - CategorySelectionViewController

final class CategorySelectionViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let viewModel = CategoryViewModel()
    weak var delegate: CategorySelectionViewControllerDelegate?
    var selectedCategoryTitle: String?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tintColor = .bluetracker
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blacktracker
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
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
        label.text = "Привычки и события можно\nобъединить по смыслу"
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
        view.backgroundColor = .white
        title = "Категория"
        
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            
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
        let hasCategories = viewModel.numberOfCategories() > 0
        tableView.isHidden = !hasCategories
        placeholderImageView.isHidden = hasCategories
        placeholderLabel.isHidden = hasCategories
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] in
            self?.tableView.reloadData()
            self?.reloadPlaceholderVisibility()
        }
        reloadPlaceholderVisibility()
    }
    
    @objc private func didTapAddCategoryButton() {
        let newCategoryVC = NewCategoryViewController()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0)
        cell.selectionStyle = .none
        
        let currentCategoryTitle = viewModel.categoryTitle(at: indexPath)
        cell.textLabel?.text = currentCategoryTitle
        
        let isSelected = (currentCategoryTitle == selectedCategoryTitle)
        cell.accessoryType = isSelected ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTitle = viewModel.categoryTitle(at: indexPath)
        
        selectedCategoryTitle = selectedTitle
        
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.delegate?.didSelectCategory(selectedTitle)
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
// MARK: - NewCategoryViewControllerDelegate

extension CategorySelectionViewController: NewCategoryViewControllerDelegate {
    func didCreateCategory(with title: String) {
        viewModel.addCategory(title: title)
    }
}
