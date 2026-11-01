import UIKit

// MARK: - NewCategoryViewControllerDelegate

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didCreateCategory(with title: String)
}

// MARK: - NewCategoryViewController

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: NewCategoryViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private lazy var categoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0)
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1.0)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapReadyButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    // MARK: - Actions
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let isNotEmpty = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        readyButton.isEnabled = isNotEmpty
        readyButton.backgroundColor = isNotEmpty ? .black : UIColor(red: 0.68, green: 0.69, blue: 0.71, alpha: 1.0)
    }
    
    @objc private func didTapReadyButton() {
        guard let categoryTitle = categoryNameTextField.text, !categoryTitle.isEmpty else { return }
        delegate?.didCreateCategory(with: categoryTitle)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupScreen() {
        view.backgroundColor = .white
        title = "Новая категория"
        navigationItem.hidesBackButton = false
        view.addSubview(categoryNameTextField)
        view.addSubview(readyButton)
        
        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

