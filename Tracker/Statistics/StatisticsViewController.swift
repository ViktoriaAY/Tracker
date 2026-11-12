import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let recordStore = TrackerRecordStore()
    
    private let statisticCardView: StatisticCardView = {
        let view = StatisticCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "error_statistic")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "empty_statistics_placeholder".localized
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .blacktracker
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    // MARK: - Private Methods
    
    private func setupNavBar() {
        title = "statistics_title".localized
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whitetracker
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupScreen() {
        view.backgroundColor = .whitetracker
        
        view.addSubview(statisticCardView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            statisticCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            statisticCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticCardView.heightAnchor.constraint(equalToConstant: 90),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func updateStatistics() {
        let completedCount = recordStore.records.count
        
        let hasData = completedCount > 0
        statisticCardView.isHidden = !hasData
        placeholderImageView.isHidden = hasData
        placeholderLabel.isHidden = hasData
        
        if hasData {
            statisticCardView.configure(
                count: completedCount,
                title: "completed_trackers_stat".localized
            )
        }
    }
}
