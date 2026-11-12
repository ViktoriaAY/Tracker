import UIKit

// MARK: - TrackerFilter Enum

enum TrackerFilter: Int, CaseIterable {
    case all = 0
    case today
    case completed
    case uncompleted
    
    var title: String {
        switch self {
        case .all: return "filter_all".localized
        case .today: return "filter_today".localized
        case .completed: return "filter_completed".localized
        case .uncompleted: return "filter_uncompleted".localized
        }
    }
    
    var showsCheckmark: Bool {
        return self == .completed || self == .uncompleted
    }
}

// MARK: - FiltersViewControllerDelegate

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

// MARK: - FiltersViewController

final class FiltersViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: FiltersViewControllerDelegate?
    var selectedFilter: TrackerFilter = .all
    
    // MARK: - Private Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .backgroundtracker
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .graytracker
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tintColor = .bluetracker
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    // MARK: - Private Methods
    
    private func setupScreen() {
        view.backgroundColor = .whitetracker
        title = "filters_button".localized
        
        view.addSubview(tableView)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300) // 4 строки * 75 поинтов
        ])
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        guard let filter = TrackerFilter(rawValue: indexPath.row) else { return cell }
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .blacktracker
        
        let shouldShowCheckmark = (filter == selectedFilter) && (filter == .completed || filter == .uncompleted)
        cell.accessoryType = shouldShowCheckmark ? .checkmark : .none
        cell.tintColor = .bluetracker
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let filter = TrackerFilter(rawValue: indexPath.row) else { return }
        selectedFilter = filter
        tableView.reloadData()
        
        delegate?.didSelectFilter(filter)
        dismiss(animated: true)
    }
}

