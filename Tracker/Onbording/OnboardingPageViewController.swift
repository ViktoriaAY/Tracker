import UIKit

// MARK: - OnboardingPageViewController

final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .blacktracker
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .blacktracker
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.whitetracker, for: .normal)
        button.setTitle("onboarding_button".localized, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let completionHandler: () -> Void
    
    // MARK: - Initializers
    
    init(imageName: String, text: String, buttonText: String, completion: @escaping () -> Void) {
        self.completionHandler = completion
        super.init(nibName: nil, bundle: nil)
        
        self.backgroundImageView.image = UIImage(named: imageName)
        self.textLabel.text = text
        self.confirmButton.setTitle(buttonText, for: .normal)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupConstraints()
    }
    
    // MARK: - Actions
    
    @objc private func didTapConfirmButton() {
        completionHandler()
    }
    
    // MARK: - Private Methods
    
    private func setupHierarchy() {
        view.addSubview(backgroundImageView)
        view.addSubview(textLabel)
        view.addSubview(confirmButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            confirmButton.heightAnchor.constraint(equalToConstant: 60),
            
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -160)
        ])
    }
}
