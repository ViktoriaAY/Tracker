import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var plusButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "plus")
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: -12,
            bottom: 0,
            trailing: 8
        )
        
        let button = UIButton(configuration: config)
        let image = UIImage(named: "plustracker")
        
        button.backgroundColor = .clear
        button.setImage(image, for: .normal)
        button.tintColor = .blacktracker
        button.addTarget(
            self,
            action: #selector(plusButtonTapped),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "de_DE")
        datePicker.addTarget(
            self,
            action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged
        )
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "search_placeholder".localized
        search.backgroundColor = .grayimage
        search.searchBarStyle = .minimal
        search.layer.cornerRadius = 10
        search.layer.masksToBounds = true
        search.delegate = self
        
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
            string: "search_placeholder".localized,
            attributes: placeholderAttributes
        )
        
        if let glassIconView = search.searchTextField.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(
                .alwaysTemplate
            )
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
        label.text = "empty_trackers_placeholder".localized
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .blacktracker
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 16, right: 16)
        
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("filters_button".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.backgroundColor = .bluetracker
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date = Date()
    private var completedTrackers: Set<TrackerRecord> = []
    private lazy var categoryStore = TrackerCategoryStore()
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchText: String = ""
    private lazy var trackerStore = TrackerStore()
    private lazy var recordStore = TrackerRecordStore()
    private var currentFilter: TrackerFilter = .all
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .whitetracker
        
        setupNavBar()
        setupSearchController()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: "Header"
        )
        collectionView.register(
            TrackersSectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackersSectionHeader.identifier
        )
        
        if let datePickerView = datePicker.subviews.first?.subviews.first {
            datePickerView.backgroundColor = .clear
            datePickerView.subviews.forEach { $0.backgroundColor = .clear }
        }
        
        setupHierarchy()
        setupConstraints()
        
        _ = TrackerCategory(title: "default_category_title".localized, trackers: [])
        
        _ = Calendar.current.component(
            .weekday,
            from: datePicker.date
        )
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTrackersFromCoreData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: .open, screen: .main)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.report(event: .close, screen: .main)
    }
    // MARK: - Setup Navigation Bar
    
    private func loadTrackersFromCoreData() {
        let savedCategories = self.categoryStore.categories
        self.categories = savedCategories
        
        completedTrackers = Set(recordStore.records)
        
        filterTrackers()
    }
    
    private func setupNavBar() {
        title = "trackers_title".localized
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whitetracker
        appearance.shadowColor = .whitetracker
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: plusButton
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: datePicker
        )
    }
    
    // MARK: - Setup UI
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "search_placeholder".localized
        
        definesPresentationContext = true
    }
    
    private func setupHierarchy() {
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 0
            ),
            searchBar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            searchBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(
                equalTo: searchBar.bottomAnchor,
                constant: 10
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            
            placeholderImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            placeholderImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(
                equalTo: placeholderImageView.bottomAnchor,
                constant: 8
            ),
            placeholderLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            placeholderLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    // MARK: - Actions
    @objc private func filterButtonTapped() {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .filter)
        let filtersVC = FiltersViewController()
        filtersVC.delegate = self
        filtersVC.selectedFilter = currentFilter
        let navigationController = UINavigationController(rootViewController: filtersVC)
        present(navigationController, animated: true)
    }
    
    @objc private func plusButtonTapped() {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .addTrack)
        let habitCreationVC = HabitCreationViewController()
        habitCreationVC.delegate = self
        let navigationController = UINavigationController(
            rootViewController: habitCreationVC
        )
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        self.categories = categoryStore.categories
        
        filterTrackers()
    }
    
    // MARK: - Filtering Logic
    
    func filterTrackers() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: datePicker.date)
        let trackersForSelectedDate = categories.flatMap { category in
            category.trackers.filter { tracker in
                tracker.schedule?.isScheduled(on: weekday) ?? true
            }
        }
        
        filterButton.isHidden = trackersForSelectedDate.isEmpty
        
        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesSchedule = tracker.schedule?.isScheduled(on: weekday) ?? true
                let matchesSearch = searchText.isEmpty || tracker.title.lowercased().contains(searchText.lowercased())
                
                let isCompletedOnDate = completedTrackers.contains { record in
                    record.id == tracker.id && calendar.isDate(record.date, inSameDayAs: datePicker.date)
                }
                
                let matchesFilter: Bool
                switch currentFilter {
                case .all, .today:
                    matchesFilter = true
                case .completed:
                    matchesFilter = isCompletedOnDate
                case .uncompleted:
                    matchesFilter = !isCompletedOnDate
                }
                
                return matchesSchedule && matchesSearch && matchesFilter
            }
            
            if !filteredTrackers.isEmpty {
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
            return nil
        }
        
        collectionView.reloadData()
        
        let isVisibleEmpty = visibleCategories.isEmpty
        placeholderImageView.isHidden = !isVisibleEmpty
        placeholderLabel.isHidden = !isVisibleEmpty
        
        if isVisibleEmpty {
            if trackersForSelectedDate.isEmpty {
                placeholderImageView.image = UIImage(named: "error_image")
                placeholderLabel.text = "empty_trackers_placeholder".localized
            } else {
                placeholderImageView.image = UIImage(named: "nothing_found_image")
                placeholderLabel.text = "nothing_found_placeholder".localized
            }
        }
    }
    
    private func editTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        let editVC = HabitCreationViewController()
        editVC.delegate = self
        editVC.editingTracker = tracker
        editVC.editingCategoryTitle = visibleCategories[indexPath.section].title
        editVC.completedDaysCount = completedTrackers.filter { $0.id == tracker.id }.count
        
        let navigationController = UINavigationController(rootViewController: editVC)
        present(navigationController, animated: true)
    }
    
    private func showDeleteConfirmation(for tracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: "delete_tracker_confirmation".localized,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(title: "delete_action".localized, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            do {
                try self.trackerStore.deleteTracker(with: tracker.id)
                
                self.completedTrackers = self.completedTrackers.filter { $0.id != tracker.id }
                
                self.loadTrackersFromCoreData()
            } catch {
                print("❌ Ошибка при удалении трекера: \(error)")
                assertionFailure("Не удалось удалить трекер из Core Data: \(error.localizedDescription)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel_button".localized, style: .cancel)
        cancelAction.setValue(UIColor.systemBlue, forKey: "titleTextColor")
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let isCompleted = completedTrackers.contains { record in
            record.id == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: datePicker.date)
        }
        
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        
        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackersSectionHeader.identifier,
            for: indexPath
        ) as? TrackersSectionHeader else {
            return UICollectionReusableView()
        }
        
        let categoryTitle = visibleCategories[indexPath.section].title
        headerView.configure(with: categoryTitle)
        
        return headerView
    }
}

// MARK: - TrackerCollectionViewCellDelegate

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func didTapCompleteButton(in cell: TrackerCollectionViewCell) {
        AnalyticsService.shared.report(event: .click, screen: .main, item: .track)
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let selectedDate = datePicker.date
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dateToCheck = calendar.startOfDay(for: selectedDate)
        
        if dateToCheck > today {
            print("Попытка отметить трекер для будущей даты заблокирована")
            return
        }
        
        let recordToFind = completedTrackers.first { record in
            calendar.isDate(record.date, inSameDayAs: selectedDate)
            && record.id == tracker.id
        }
        
        if let record = recordToFind {
            completedTrackers.remove(record)
            do {
                try recordStore.remove(record)
            } catch {
                print("❌ Ошибка удаления записи из Core Data: \(error)")
            }
        } else {
            let newRecord = TrackerRecord(id: tracker.id, date: dateToCheck)
            completedTrackers.insert(newRecord)
            do {
                try recordStore.add(newRecord)
            } catch {
                print("❌ Ошибка сохранения записи в Core Data: \(error)")
            }
        }
        
        collectionView.reloadItems(at: [indexPath])
        filterTrackers()
    }
    
}

// MARK: - HabitCreationViewControllerDelegate

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
        loadTrackersFromCoreData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let numberOfColumns: CGFloat = 2
        let paddingSpace: CGFloat = 16 * 2 + 9
        let collectionViewWidth = collectionView.frame.width
        
        guard collectionViewWidth > 0 else {
            return CGSize(width: 167, height: 148)
        }
        
        let availableWidth = collectionViewWidth - paddingSpace
        let widthPerItem = floor(availableWidth / numberOfColumns)
        
        return CGSize(width: widthPerItem, height: 148)
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 9
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 24)
    }
    
    // MARK: - Context Menu
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            
            let editAction = UIAction(title: "edit_action".localized) { _ in
                AnalyticsService.shared.report(event: .click, screen: .main, item: .edit)
                self.editTracker(tracker, at: indexPath)
            }
            
            let deleteAction = UIAction(title: "delete_action".localized, attributes: .destructive) { _ in
                AnalyticsService.shared.report(event: .click, screen: .main, item: .delete)
                self.showDeleteConfirmation(for: tracker)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return nil
        }
        return UITargetedPreview(view: cell.previewView)
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchText = searchController.searchBar.text ?? ""
        filterTrackers()
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filterTrackers()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - FiltersViewControllerDelegate

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        if filter == .today {
            datePicker.date = Date()
        }
        filterTrackers()
    }
}
