import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var plusButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "plus")
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: -12, bottom: 0, trailing: 8)
        
        let button = UIButton(configuration: config)
        let image = UIImage(named: "plustracker")
        
        button.backgroundColor = .clear
        button.setImage(image, for: .normal)
        button.tintColor = .blacktracker
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "de_DE")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Поиск"
        search.backgroundColor = .grayimage
        search.searchBarStyle = .minimal
        search.layer.cornerRadius = 10
        search.layer.masksToBounds = true
        search.translatesAutoresizingMaskIntoConstraints = false
        
        search.searchTextField.borderStyle = .none
        search.searchTextField.backgroundColor = .clear
        search.searchTextField.layer.cornerRadius = 0
        search.searchTextField.layer.masksToBounds = false
        
        let placeholderColor = UIColor.graytracker
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeholderColor
        ]
        
        search.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: placeholderAttributes
        )
        
        if let glassIconView = search.searchTextField.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .graytracker
        }
        
        return search
    }()
    
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "error_image")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .blacktracker
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private var currentWeekDay: Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        
        let weekday = calendar.component(.weekday, from: datePicker.date)
        
        let correctedWeekday = (weekday + 5) % 7 + 1
        return correctedWeekday
    }
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date = Date()
    private var completedTrackers: Set<TrackerRecord> = []
    private lazy var categoryStore = TrackerCategoryStore()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whitetracker
        
        setupNavBar()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
        if let datePickerView = datePicker.subviews.first?.subviews.first {
            datePickerView.backgroundColor = .clear
            datePickerView.subviews.forEach { $0.backgroundColor = .clear }
        }
        
        setupHierarchy()
        setupConstraints()
        
        _ = TrackerCategory(title: "Домашний уют", trackers: [])
        
        let weekdayIndex = Calendar.current.component(.weekday, from: datePicker.date)
        filterTrackersByDate(weekdayIndex: weekdayIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTrackersFromCoreData()
    }
    
    // MARK: - Setup Navigation Bar
    
    private func loadTrackersFromCoreData() {
        let savedCategories = self.categoryStore.categories
        
        self.categories = savedCategories
        
        let weekdayIndex = Calendar.current.component(.weekday, from: datePicker.date)
        filterTrackersByDate(weekdayIndex: weekdayIndex)
        
        collectionView.reloadData()
    }
    
    
    private func setupNavBar() {
        title = "Трекеры"
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whitetracker
        appearance.shadowColor = .whitetracker
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    // MARK: - Setup UI
    
    private func setupHierarchy() {
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func plusButtonTapped() {
        let habitCreationVC = HabitCreationViewController()
        habitCreationVC.delegate = self
        let navigationController = UINavigationController(rootViewController: habitCreationVC)
        present(navigationController, animated: true)
    }
    
    private func filterTrackers(for weekdayIndex: Int) {
        collectionView.reloadData()
        
        let isTrackersEmpty = visibleCategories.isEmpty
        placeholderImageView.isHidden = !isTrackersEmpty
        placeholderLabel.isHidden = !isTrackersEmpty
    }
    
    private func filterTrackersByDate(weekdayIndex: Int) {
        visibleCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                guard let schedule = tracker.schedule else { return true }
                return schedule.isScheduled(on: weekdayIndex)
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
            
        }.filter { !$0.trackers.isEmpty }
        
        collectionView.reloadData()
        
        let isTrackersEmpty = visibleCategories.isEmpty
        placeholderImageView.isHidden = !isTrackersEmpty
        placeholderLabel.isHidden = !isTrackersEmpty
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        self.currentDate = sender.date
        
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: currentDate)
        
        filterTrackersByDate(weekdayIndex: weekdayIndex)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let isCompletedToday = completedTrackers.contains { record in
            let isSameDay = Calendar.current.isDate(record.date, inSameDayAs: currentDate)
            return record.id == tracker.id && isSameDay
        }
        
        let completedDaysCount = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell.delegate = self
        cell.configure(with: tracker, isCompleted: isCompletedToday, completedDays: completedDaysCount)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
        
        header.subviews.forEach { $0.removeFromSuperview() }
        
        let label = UILabel()
        label.text = visibleCategories[indexPath.section].title
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        header.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: header.topAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 28),
            label.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor)
        ])
        
        return header
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didTapCompleteButton(in cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let selectedDate = datePicker.date
        
        if selectedDate > Date() && !Calendar.current.isDateInToday(selectedDate) {
            print("Попытка отметить трекер для будущей даты заблокирована")
            return
        }
        
        let recordToFind = completedTrackers.first { record in
            Calendar.current.isDate(record.date, inSameDayAs: selectedDate) && record.id == tracker.id
        }
        
        if let record = recordToFind {
            completedTrackers.remove(record)
        } else {
            let newRecord = TrackerRecord(id: tracker.id, date: selectedDate)
            completedTrackers.insert(newRecord)
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackersViewController: HabitCreationViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, toCategory categoryTitle: String) {
        
        let updatedCategories = categories.map { category -> TrackerCategory in
            if category.title == categoryTitle {
                var newTrackers = category.trackers
                newTrackers.append(tracker)
                
                return TrackerCategory(title: category.title, trackers: newTrackers)
            }
            return category
        }
        self.categories = updatedCategories
        
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: datePicker.date)
        
        filterTrackersByDate(weekdayIndex: weekdayIndex)
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - 32 - 9
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 46)
    }
}




